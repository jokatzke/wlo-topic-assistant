{
  stdenv,
  nix-filter,
  fetchgit,
  buildPythonApplication,
  fastapi,
  pydantic,
  uvicorn,
  rdflib,
  nltk,
  sentence-transformers,
  scikit-learn,
  pandas,
  torch,
  treelib,
  nltk-data,
  oeh-metadata-vocabs,
}:
let
  all-mpnet-base-v2 = fetchgit {
    url = "https://huggingface.co/sentence-transformers/all-mpnet-base-v2";
    rev = "bd44305fd6a1b43c16baf96765e2ecb20bca8e1d";
    hash = "sha256-lsKdkbIeAUZIieIaCmp1FIAP4NAo4HW2W7+6AOmGO10=";
    fetchLFS = true;
  };

  # shared specification between pre-loader and web service
  wlo-topic-assistant-spec = {
    version = "0.1.4";
    propagatedBuildInputs = [
      fastapi
      pydantic
      uvicorn
      rdflib
      nltk
      sentence-transformers
      scikit-learn
      pandas
      torch
      treelib
    ];
    # make the stopwords discoverable for nltk
    env.NLTK_DATA = nltk-data.stopwords;
    makeWrapperArgs = [ "--set NLTK_DATA ${nltk-data.stopwords}" ];
  };

  # build pre-loader; this creates the topic assistants at build time
  wlo-topic-assistant-preload = buildPythonApplication (
    wlo-topic-assistant-spec
    // {
      pname = "wlo-topic-assistant-preload";
      # prevent unnecessary rebuilds
      src = nix-filter {
        root = ./.;
        include = [
          ./src/wlo_topic_assistant/__init__.py
          ./src/wlo_topic_assistant/_version.py
          ./src/wlo_topic_assistant/generate_assistants.py
          ./src/wlo_topic_assistant/topic_assistant.py
          ./src/wlo_topic_assistant/topic_assistant2.py
          ./setup.py
          ./requirements.txt
        ];
        exclude = [
          (nix-filter.matchExt "pyc")
          (nix-filter.matchExt "ipynb")
        ];
      };
      # replace calls to resources from the internet with prefetched ones
      prePatch = ''
        substituteInPlace src/wlo_topic_assistant/*.py \
          --replace \
            "all-mpnet-base-v2" \
            "${all-mpnet-base-v2}" \
          --replace \
            "https://raw.githubusercontent.com/openeduhub/oeh-metadata-vocabs/master/discipline.ttl" \
            "${oeh-metadata-vocabs}/discipline.ttl" \
          --replace \
            "https://raw.githubusercontent.com/openeduhub/oeh-metadata-vocabs/master/oehTopics.ttl" \
            "${oeh-metadata-vocabs}/oehTopics.ttl"
      '';
    }
  );

  # run the pre-loader to create the topic assistants at build time
  wlo-topic-assistant-assistants = stdenv.mkDerivation {
    pname = "wlo-topic-assistant-assistants";
    version = wlo-topic-assistant-preload.version;
    src = wlo-topic-assistant-preload.src;
    # nativeBuildInputs = [
    #   wlo-topic-assistant-preload
    # ];
    installPhase = ''
      export HF_HOME=$TMPDIR
      mkdir $out
      ${wlo-topic-assistant-preload}/bin/preload $out
    '';
  };
in
# actually build the application
buildPythonApplication (
  wlo-topic-assistant-spec
  // {
    pname = "wlo-topic-assistant";
    src = nix-filter {
      root = ./.;
      include = [
        "src"
        ./setup.py
        ./requirements.txt
      ];
      exclude = [
        (nix-filter.matchExt "pyc")
        (nix-filter.matchExt "ipynb")
      ];
    };
    # set the path of the topic assistants
    prePatch = ''
      substituteInPlace src/wlo_topic_assistant/webservice.py \
        --replace \
          "data/" \
          "${wlo-topic-assistant-assistants}/"
    '';
  }
)
