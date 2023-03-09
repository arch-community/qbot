{
	description = "qbot flake";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
		flake-utils.url = "github:numtide/flake-utils";
	};

	outputs = { self
			, nixpkgs
			, flake-utils }:
		rec {
			overlay = final: prev: {
				qbot = final.callPackage ./. { };
			};

			nixosModules = rec {
				qbot = import ./module.nix;
				default = qbot;
			};
		} //
	flake-utils.lib.eachDefaultSystem (system:
		let
			pkgs = import nixpkgs {
				inherit system;
				config.allowUnfree = true;
			};

			pkg = pkgs.callPackage ./. { };
			app = flake-utils.lib.mkApp { drv = pkg; name = "qbot"; };
			shell = import ./shell.nix { inherit pkgs; };
		in rec {
			packages.qbot = pkg;
			packages.default = pkg;

			apps.qbot = app;
			apps.default = app;

			devShells.qbot = shell;
			devShells.default = shell;
		}
	);
}
