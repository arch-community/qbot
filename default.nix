let
  pkgs = (import <nixpkgs> { config.allowUnfree = true; });

  oracle = pkgs.symlinkJoin {
    name = "instantclient";
    paths = with pkgs.oracle-instantclient; [ out lib dev ];
    postBuild = ''
      mkdir -p $out/lib/sdk
      ln -s ${pkgs.oracle-instantclient.dev}/include $out/lib/sdk/include
    '';
  };

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
      ruby-oci8 = attrs: {
        LD_LIBRARY_PATH = "${oracle}/lib";
      };
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
    env.wrappedRuby env bundix'
    git
    sqlite libxml2 zlib.dev zlib libiconv
    oracle-instantclient oracle
    libopus libsodium ffmpeg youtube-dl
  ];

  LD_LIBRARY_PATH = with pkgs; "${libsodium}/lib:${libopus}/lib:${oracle}/lib";
  NLS_LANG = "American_America.UTF8";

  installPhase = ''
    mkdir -p $out/{bin,share/qbot}
    cp -r * $out/share/qbot
    bin=$out/bin/qbot

    cat >$bin <<EOF
#!/bin/sh -e
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}
cd $out/share/qbot
exec ${bundler'}/bin/bundle exec ${ruby'}/bin/ruby $out/share/qbot/qbot "\$@"
EOF

    chmod +x $bin
  '';
}
