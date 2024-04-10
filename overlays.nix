{
  lib,
  nix-filter,
  oeh-metadata-vocabs,
}:
rec {
  default = wlo-topic-assistant;

  # add additional packages / external dependencies
  fix-nixpkgs = (final: prev: { inherit oeh-metadata-vocabs; });

  # add the standalone python application
  wlo-topic-assistant = lib.composeExtensions fix-nixpkgs (
    final: prev: {
      wlo-topic-assistant = final.python3Packages.callPackage ./package.nix { inherit nix-filter; };
    }
  );
}
