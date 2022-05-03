{
  description = "qbot flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    rec {
      overlay = final: prev: let
        pkgs = import nixpkgs { 
        	inherit (prev) system;
        	config.allowUnfree = true;
        };
      in rec {
        qbot = pkgs.callPackage ./. { };
      };

      nixosModule = import ./module.nix;
      nixosModules = [ nixosModule ];
    } //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          overlays = [ self.overlay ];
          inherit system;
          config.allowUnfree = true;
        };

        pkg = pkgs.qbot;
        app = flake-utils.lib.mkApp { drv = pkg; name = "qbot"; };
        shell = import ./shell.nix { inherit pkgs; };
      in rec {
        packages.qbot = pkg;
        packages.default = pkg;

        legacyPackages.qbot = pkg;

        apps.qbot = app;
        apps.default = app;

        devShells.qbot = shell;
        devShells.default = shell;
      }
    );
}
