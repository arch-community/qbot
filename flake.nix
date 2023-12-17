rec {
	description = "qbot flake";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";

		# TODO: remove once nixpkgs#272969 is merged
		rust-overlay.url = "github:oxalica/rust-overlay";

		gitignore.url = "github:hercules-ci/gitignore.nix";
		gitignore.inputs.nixpkgs.follows = "nixpkgs";
	};

	nixConfig = {
		extra-substituters = "https://qbot.cachix.org";
		extra-trusted-public-keys =
			"qbot.cachix.org-1:xkDcKYI5RucucGnOvREbPYj3+Ld1iVco0UFNQj1JVc8=";
	};

	outputs = { self
		, nixpkgs
		, rust-overlay
		, gitignore
		}@flakes:
	let
		# forEachSystem : (Str -> Set Any) -> Set (Set Any);
		forEachSystem = let
			inherit (nixpkgs.lib) genAttrs systems;
		in 
			genAttrs systems.flakeExposed;

		qbotPkgArgs = pkgs: rec {
			ruby = pkgs.ruby_3_2;
			bundler = pkgs.bundler.override { inherit ruby; };
			bundix = pkgs.bundix.override { inherit bundler; };

			# TODO: remove once nixpkgs#272969 is merged
			rustc = rust-overlay.packages.${pkgs.system}.rust;
			cargo = rustc;

			inherit (gitignore.lib) gitignoreSource;
		};

		commonEnv = system: rec {
			pkgs = import nixpkgs {
				inherit system;
				config.allowUnfree = true;
			};

			qbot = pkgs.callPackage ./. (qbotPkgArgs pkgs);
		};

		# withCommon : (Dict Any -> Dict Any) -> Dict (Dict Any)
		withCommon = fn: forEachSystem (system: fn (commonEnv system));

	in {
		overlays = rec {
			qbot = final: prev: {
				qbot = final.callPackage ./. (qbotPkgArgs final);
			};

			default = qbot;
		};

		nixosModules = rec {
			qbot = import ./module.nix { inherit nixConfig; };
			default = qbot;
		};

		packages = withCommon (env: {
			inherit (env) qbot;
			default = env.qbot;
		});

		devShells = withCommon (env: let
			shell = import ./shell.nix {
				inherit (env) pkgs;
				pkg = env.qbot;
			}; 
		in {
			qbot = shell;
			default = shell;
		});

		apps = withCommon (env: let
			inherit (env) pkgs;

			pkgArgs = qbotPkgArgs pkgs;

			update-deps = pkgs.writeShellApplication {
				name = "update-deps";

				runtimeInputs = [ pkgArgs.bundler pkgArgs.bundix ];

				text = ''
					rm -f Gemfile.lock

					bundle lock \
						--add-platform ruby \
						--remove-platform x86_64-linux \
					|| bundle lock \
						--add-platform ruby

					bundix
				'';
			};

		in {
			update-deps = {
				type = "app";
				program = nixpkgs.lib.getExe update-deps;
			};
		});
	};
}
