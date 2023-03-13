{
	description = "qbot flake";

	inputs = {
		nixpkgs.url = github:nixos/nixpkgs/nixos-unstable-small;
		flake-utils.url = github:numtide/flake-utils;

		gitignore.url = github:hercules-ci/gitignore.nix;
		gitignore.inputs.nixpkgs.follows = "nixpkgs";

		bundix.url = github:nix-community/bundix;
		bundix.flake = false;
	};

	outputs = { self
			, nixpkgs
			, flake-utils
			, ... }@flakes:
	let
		qbotPackage = pkgs: let
			ruby = pkgs.ruby_3_1;
			bundler = pkgs.bundler.override { inherit ruby; };

			# release bundix does not run on ruby >2.7
			# pin to master, which has support
			bundix = (pkgs.bundix.overrideAttrs (_: {
				src = flakes.bundix;
			})).override { inherit bundler; };
		in
			pkgs.callPackage ./. {
				inherit flakes ruby bundler bundix;
			};

	in {
		overlay = final: prev: { qbot = qbotPackage final; };

		nixosModules = rec {
			qbot = import ./module.nix;
			default = qbot;
		};

	} // flake-utils.lib.eachDefaultSystem (system:
		let
			pkgs = import nixpkgs {
				inherit system;
				config.allowUnfree = true;
			};

			pkg = qbotPackage pkgs;
			shell = import ./shell.nix { inherit pkgs pkg; };

			update-deps = pkgs.writeShellApplication {
				name = "update-deps";
				runtimeInputs = with pkg.passthru; [ bundler bundix ];

				text = ''
					rm Gemfile.lock
					bundle lock
					bundix
				'';
			};

		in {
			packages = rec {
				qbot = pkg;
				default = qbot;
			};

			devShells = rec {
				qbot = shell;
				default = qbot;
			};

			apps = {
				update-deps = flake-utils.lib.mkApp { drv = update-deps; };
			};
		}
	);
}
