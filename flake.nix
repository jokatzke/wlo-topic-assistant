{
  description = "The WLO topic assistant, packaged in pure Nix";

  inputs = {
    # stable branch of the nix package repository
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # utilities
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
    # automatic testing of the service
    openapi-checks = {
      url = "github:openeduhub/nix-openapi-checks";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    # external data that is versioned through the flake.lock
    oeh-metadata-vocabs = {
      url = "github:openeduhub/oeh-metadata-vocabs";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    {
      # define an overlay to add wlo-topic-assistant to nixpkgs
      overlays = import ./overlays.nix {
        inherit (nixpkgs) lib;
        inherit (self.inputs) oeh-metadata-vocabs;
        nix-filter = self.inputs.nix-filter.lib;
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        # import the packages from nixpkgs
        pkgs = nixpkgs.legacyPackages.${system}.extend self.outputs.overlays.default;
      in
      {
        # the packages that we can build
        packages = rec {
          inherit (pkgs) wlo-topic-assistant;
          default = wlo-topic-assistant;
          docker = pkgs.callPackage ./docker.nix { };
        };
        # the development environment
        devShells.default = pkgs.callPackage ./shell.nix { };
        checks =
          { }
          // (nixpkgs.lib.optionalAttrs
            # only run the VM checks on linux systems
            (system == "x86_64-linux" || system == "aarch64-linux")
            {
              test-service = self.inputs.openapi-checks.lib.${system}.test-service {
                service-bin = "${pkgs.wlo-topic-assistant}/bin/wlo-topic-assistant";
                service-port = 8080;
                openapi-domain = "/openapi.json";
                memory-size = 4096;
              };
            }
          );
      }
    );
}
