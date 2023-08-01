rec {
	description = "qbot flake";

	inputs = {
		nixpkgs.url = github:nixos/nixpkgs/nixos-unstable-small;

		gitignore.url = github:hercules-ci/gitignore.nix;
		gitignore.inputs.nixpkgs.follows = "nixpkgs";
	};

	nixConfig = {
		extra-substituters = "https://qbot.cachix.org";
		extra-trusted-public-keys =
			"qbot.cachix.org-1:xkDcKYI5RucucGnOvREbPYj3+Ld1iVco0UFNQj1JVc8=";
	};

	outputs = { self
		, nixpkgs
		, ... }@flakes:
	let
		# compose : (b -> c) -> (a -> b) -> a -> c
		compose = f: g: x: f (g x);

		# forEachSystem : (Str -> Set Any) -> Set (Set Any);
		forEachSystem = with nixpkgs.lib; genAttrs systems.flakeExposed;

		# mkWithEnv : (Str -> Set Any) -> (Set Any -> Set Any) -> Set Any
		mkWithEnv = envFn: fn: system: let
			env = { inherit system; } // (envFn system);
		in
			fn env;

		mkPkgArgs = system: pkgs: rec {
			ruby = pkgs.ruby_3_2;
			bundler = pkgs.bundler.override { inherit ruby; };
			bundix = pkgs.bundix.override { inherit bundler; };

			inherit (flakes.gitignore.lib) gitignoreSource;
		};

		# eachSystemEnv : (Set Any -> Set Any) -> Set (Set Any)
		eachSystemEnv = compose forEachSystem (mkWithEnv (system: rec {
			pkgs = import nixpkgs {
				inherit system;
				config.allowUnfree = true;
			};

			qbot = pkgs.callPackage ./. (mkPkgArgs system pkgs);
		}));
		
	in {
		overlays = let
			overlay = final: prev: {
				qbot = final.callPackage ./. (mkPkgArgs final.system final);
			};
		in {
			qbot = overlay;
			default = overlay;
		};

		nixosModules = rec {
			qbot = import ./module.nix { inherit nixConfig; };
			default = qbot;
		};

		packages = eachSystemEnv (env: with env; {
			inherit qbot;
			default = qbot;
		});

		devShells = eachSystemEnv (env: with env; let
			shell = import ./shell.nix { inherit pkgs; pkg = qbot; }; 
		in {
			qbot = shell;
			default = shell;
		});

		apps = eachSystemEnv (env: with env; let
			update-deps = pkgs.writeShellApplication {
				name = "update-deps";

				runtimeInputs = with (mkPkgArgs system pkgs); [
					bundler bundix
				];

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
