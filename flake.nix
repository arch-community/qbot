{
  description = "qbot flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages.qbot = pkgs.callPackage ./. {};
        defaultPackage = packages.qbot;

        apps.qbot = flake-utils.lib.mkApp { drv = packages.qbot; };
        defaultApp = apps.qbot;

        legacyPackages.qbot = packages.qbot;
        overlays = self: super: { qbot = packages.qbot; };

        nixosModule = { config }: { imports = [ ./module.nix ]; };
      }
    );
}
