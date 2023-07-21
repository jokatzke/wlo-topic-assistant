# WLO Topic Assistant

A utility to map arbitrary text to the WLO/OEH topics vocabulary based on keyword matching.

### Docker Installation
 
## Prerequisites

- Install [Docker](https://docker.com/).
- Build the Docker container.

```
sh build.sh
```

- To test the prediction just execute the script with an arbitrary text.

```
sh runPrediction.sh "Im Englisch Unterricht behandeln wir heute Verben, Past Perfect und False Friends"
```

The result is a JSON output containing a tree like:

```
WLO
├── Englisch (4) [englisch]
│   ├── Grammatik (2)
│   │   └── Verben (2) [verben]
│   │       └── Past (1) [past]
│   └── Sprache und Aussprache (1)
│       └── False friends (1) [false friends]
├── Deutsch als Zweitsprache (3)
│   ├── Grammatik (2)
│   │   ├── Adverbien (1)
│   │   │   └── Temporaladverbien (1) [heute]
│   │   └── Verben (1) [verben]
│   └── Wortschatz (1)
│       └── Schule und Studium (1) [englisch]
├── Spanisch (1)
│   └── Grammatik (1)
│       └── Verben (1) [verben]
├── Deutsch (1)
│   └── Grammatik und Sprache untersuchen (1)
│       └── Wortarten (1)
│           └── Verben (1) [verben]
└── Türkisch (1)
    └── Grammatik (1)
        └── Verben (1) [verben]
```

```
{"WLO": {"children": [{"Englisch (2) [englisch]": {"children": [{"Sprache und Aussprache (1)": {"children": [{"False friends (1) [false friends]": {"data": {"w": 1, "label": "False friends", "match": "false friends"}}}], "data": {"w": 1, "label": "Sprache und Aussprache"}}}], "data": {"w": 2, "uri": "http://w3id.org/openeduhub/vocabs/oehTopics/15dbd166-fd31-4e01-aabd-524cfa4d2783", "label": "Englisch", "match": "englisch"}}}, {"Deutsch als Zweitsprache (1)": {"children": [{"Wortschatz (1)": {"children": [{"Schule und Studium (1) [englisch]": {"data": {"w": 1, "label": "Schule und Studium", "match": "englisch"}}}], "data": {"w": 1, "label": "Wortschatz"}}}], "data": {"w": 1, "uri": "http://w3id.org/openeduhub/vocabs/oehTopics/26a336bf-51c8-4b91-9a6c-f1cf67fd4ae4", "label": "Deutsch als Zweitsprache"}}}], "data": {"w": 3, "uri": "http://w3id.org/openeduhub/vocabs/oehTopics/5e40e372-735c-4b17-bbf7-e827a5702b57"}}}
```

This tree is a subset of the OEH-Topics taxonomy. The number in brackets indicates the number of matches found in the text. This number gets accumulated along the path of a leaf to the root. The terms in square brackets indicate the matching keywords.

## Webservice

- To run the subject prediction tool as a simple REST based webservice, the following script can be used:

```
sh runService.sh
```

- The scripts deploys a CherryPy webservice in a docker container listening at `http://localhost:8080/topics`.

- To retrieve the topics, create a POST request and submit a json document with a text as for example: 

```
curl -d '{"text" : "Im Englisch Unterricht behandeln wir heute Verben, Past Perfect und False Friends"}' -H "Content-Type: application/json" -X POST http://0.0.0.0:8080/topics
```	

### Nix Installation

## Prerequisites

- Install the [Nix](https://nixos.org/) package manager through one off the following methods:
  - [unofficial installer](https://github.com/DeterminateSystems/nix-installer) (recommended, for Linux & macOS), or 
  - the official installer [for Linux](https://nixos.org/download.html#nix-install-linux) or [for macOS](https://nixos.org/download.html#nix-install-macos)
    - If installing through the official installer, enable the experimental `Flakes` feature: https://nixos.wiki/wiki/Flakes#Permanent 

## Webservice

- Build the `Docker` image for the web-service:
```
nix build
```

- Run the web-service, noting the version that was supplied:

```
docker run -p 8080:8080 wlo-topic-assistant:<version>
```

- To retrieve the topics, create a POST request and submit a json document with a text as for example: 

```
curl -d '{"text" : "Im Englisch Unterricht behandeln wir heute Verben, Past Perfect und False Friends"}' -H "Content-Type: application/json" -X POST http://0.0.0.0:8080/topics
```	

