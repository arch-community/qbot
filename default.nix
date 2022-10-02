{ stdenv, lib, symlinkJoin, makeWrapper
, fetchFromGitHub
, pkg-config, git
, ruby_3_1, ruby_2_7, bundler, bundix, defaultGemConfig, bundlerEnv
, libsodium, libopus, ffmpeg, youtube-dl
, imagemagick
, sqlite, zlib, shared-mime-info, libxml2, libiconv
, figlet }:

let
  ruby = ruby_3_1;

  # release bundix does not run on ruby >2.7
  # pin to the commit that fixes it
  bundix' = bundix.overrideAttrs (_: {
  	src = fetchFromGitHub {
  		owner = "nix-community";
  		repo = "bundix";
  		rev = "3d7820efdd77281234182a9b813c2895ef49ae1f";
		sha256 = "sha256-iMp6Yj7TSWDqge3Lw855/igOWdTIuFH1LGeIN/cpq7U=";
  	};
  });

  bundlerEnv' = bundlerEnv.override { inherit ruby; };

  env = bundlerEnv' {
    name = "qbot-bundler-env";

    gemfile  = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset   = ./gemset.nix;
    gemdir   = ./.;

    inherit ruby;

    gemConfig = defaultGemConfig // {
      mimemagic = _: {
        FREEDESKTOP_MIME_TYPES_PATH = "${shared-mime-info}/share/mime/packages/freedesktop.org.xml";
      };
    };
  };
in stdenv.mkDerivation rec {
  name = "qbot";

  src = builtins.filterSource
    (path: type:
      type != "directory" ||
      baseNameOf path != "vendor" &&
      baseNameOf path != ".git" &&
      baseNameOf path != ".direnv" &&
      baseNameOf path != "var" &&
      baseNameOf path != ".bundle")
    ./.;

  buildInputs = [
    env.wrappedRuby env bundix' git pkg-config
    sqlite libxml2 zlib.dev zlib libiconv
    libopus libsodium
    ffmpeg youtube-dl
    imagemagick
  ];

  LD_LIBRARY_PATH = lib.makeLibraryPath [ libsodium libopus ];
  FONTCONFIG_FILE = "${src}/lib/resources/fc-config.xml";

  installPhase = ''
    mkdir -p $out/{bin,share/qbot}
    cp -r * $out/share/qbot
    exe=$out/bin/qbot

    cat >$exe <<EOF
#!/bin/sh -e
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}
export FONTCONFIG_FILE=${FONTCONFIG_FILE}
exec ${env}/bin/bundle exec ${env.wrappedRuby}/bin/ruby $out/share/qbot/qbot "\$@"
EOF

    chmod +x $exe
  '';
}
