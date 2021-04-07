{ stdenv, lib, symlinkJoin, makeWrapper
, pkg-config, git
, ruby_3_0, bundler, bundix, defaultGemConfig, bundlerApp
, libsodium, libopus, ffmpeg, youtube-dl
, sqlite, zlib, shared-mime-info, libxml2, libiconv
, figlet }:

let
  ruby' = pkgs.ruby_3_0;

  bundler' = pkgs.bundler.override { ruby = ruby'; };

  bundix' = pkgs.bundix.override { bundler = bundler'; };

  bundlerEnv' = pkgs.bundlerEnv.override {
    ruby = ruby';
    bundler = bundler';
  };

  env = bundlerEnv' {
    name = "qbot-bundler-env";

    gemfile  = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset   = ./gemset.nix;
    gemdir   = ./.;

    ruby = ruby';
    bundler = bundler';

    gemConfig = pkgs.defaultGemConfig // {
      nokogiri = attrs: {
        buildInputs = with pkgs; [ pkgconfig zlib.dev ];
      };
      mimemagic = attrs: {
        FREEDESKTOP_MIME_TYPES_PATH = "${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml";
      };
    };
  };
in pkgs.stdenv.mkDerivation rec {
  name = "qbot";

  src = builtins.filterSource
    (path: type:
      type != "directory" ||
      baseNameOf path != "vendor" &&
      baseNameOf path != ".git" &&
      baseNameOf path != ".bundle")
    ./.;

  buildInputs = with pkgs; [
    env.wrappedRuby env bundix' git
    sqlite libxml2 zlib.dev zlib libiconv
    libopus libsodium ffmpeg youtube-dl
  ];

  LD_LIBRARY_PATH = lib.makeLibraryPath [ libsodium libopus ];

  installPhase = ''
    mkdir -p $out/{bin,share/qbot}
    cp -r * $out/share/qbot
    bin=$out/bin/qbot

    cat >$bin <<EOF
#!/bin/sh -e
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}
cd $out/share/qbot
exec ${env}/bin/bundle exec ${env.wrappedRuby}/bin/ruby $out/share/qbot/qbot "\$@"
EOF

    chmod +x $bin
  '';
}
