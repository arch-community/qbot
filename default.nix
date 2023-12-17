{ stdenv, lib, makeWrapper
, fetchFromGitHub, gitignoreSource
, ruby, bundler, bundix, bundlerEnv, defaultGemConfig
, rustPlatform, cargo, rustc, fetchgit
, libsodium, libopus, imagemagick }:

let
	env = bundlerEnv {
		name = "qbot-bundler-env";
		gemdir = ./.;
		inherit ruby;

		gemConfig = defaultGemConfig // {
			tantiny = attrs: {
				cargoDeps = rustPlatform.fetchCargoTarball {
					src = fetchgit {
						inherit (attrs.source)
							url rev sha256 fetchSubmodules;
					};

					sha256 = "JlPkdrU2fq+0v/2QJnqtSEv3bqiJbdAvzK3NrrMdY8A=";
				};

				nativeBuildInputs = [
					rustPlatform.cargoSetupHook cargo rustc
				];

				postUnpack = ''
					mv .cargo tantiny*
				'';
			};
		};
	};

in stdenv.mkDerivation rec {
	name = "qbot";

	src = gitignoreSource ./.;

	nativeBuildInputs = [ makeWrapper ];
	buildInputs = [ env.wrappedRuby imagemagick ];
	propagatedBuildInputs = [ libopus libsodium ];

	passthru = {
		fontconfigFile = "${src}/share/fc-config.xml";
		binPath = lib.makeBinPath buildInputs;
		libPath = lib.makeLibraryPath propagatedBuildInputs;
	};

	installPhase = let
		inherit (passthru) binPath libPath fontconfigFile;
	in ''
		mkdir -p $out/{bin,share}
		cp -r . $out/share/qbot

		makeWrapper $out/share/qbot/qbot $out/bin/qbot \
			--set FONTCONFIG_FILE '${fontconfigFile}' \
			--prefix PATH : '${binPath}' \
			--prefix LD_LIBRARY_PATH : '${libPath}'
	'';

	meta = with lib; {
		description = "General purpose Discord bot";
		homepage = "https://github.com/arch-community/qbot";
		license = licenses.agpl3Plus;
		maintainers = with maintainers; [ anna328p ];
		mainProgram = "qbot";
	};
}
