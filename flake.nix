{
  description = "qbot flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    rec {
      overlay = final: prev: let
        pkgs = nixpkgs.legacyPackages.${prev.system};
      in rec {
        qbot = pkgs.callPackage ./. { };
      };

      nixosModule = { ... }: { imports = [ ./module.nix ]; };
      nixosModules = [ nixosModule ];
    } //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          overlays = [ self.overlay ];
          inherit system;
        };
      in rec {
        packages.qbot = pkgs.qbot;
        defaultPackage = packages.qbot;

        apps.qbot = flake-utils.lib.mkApp { drv = pkgs.qbot; name = "qbot"; };
        defaultApp = apps.qbot;

        legacyPackages.qbot = pkgs.qbot;
      }
    );
}
