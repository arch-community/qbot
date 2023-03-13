{ stdenv, lib, makeWrapper
, fetchFromGitHub, flakes
, ruby, bundler, bundix, bundlerEnv
, libsodium, libopus, imagemagick }:

let
	env = bundlerEnv {
		name = "qbot-bundler-env";
		gemdir = ./.;
		inherit ruby;
	};

	inherit (flakes.gitignore.lib) gitignoreSource;

in stdenv.mkDerivation rec {
	name = "qbot";

	src = gitignoreSource ./.;

	nativeBuildInputs = [ makeWrapper ];
	buildInputs = [ env.wrappedRuby imagemagick ];
	propagatedBuildInputs = [ libopus libsodium ];

	installPhase = let
		binPath = lib.makeBinPath [ env.wrappedRuby ];
		inherit (passthru) libPath fontconfigFile;
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

	passthru = {
		inherit ruby bundler bundix env;

		libPath = lib.makeLibraryPath propagatedBuildInputs;
		fontconfigFile = "${src}/lib/resources/fc-config.xml";
	};
}
