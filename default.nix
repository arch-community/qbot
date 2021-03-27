with (import <nixpkgs> { config.allowUnfree = true; });
let
  oracle = symlinkJoin {
    name = "instantclient";
    paths = with oracle-instantclient; [ out lib dev ];
    postBuild = ''
      mkdir -p $out/lib/sdk
      ln -s ${oracle-instantclient.dev}/include $out/lib/sdk/include
    '';
  };
  env = bundlerEnv {
    name = "qbot-bundler-env";
    ruby = ruby_2_7;
    gemfile  = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset   = ./gemset.nix;
    gemdir   = ./.;
    gemConfig = pkgs.defaultGemConfig // {
      ruby-oci8 = attrs: {
        LD_LIBRARY_PATH = "${oracle}/lib";
      };
      nokogiri = attrs: {
        buildInputs = [ pkgconfig zlib.dev ];
      };
      mimemagic = attrs: {
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
      baseNameOf path != ".bundle")
    ./.;

  buildInputs = [
    env.wrappedRuby
    bundler bundix
    git
    sqlite libxml2 zlib.dev zlib libiconv
    oracle-instantclient oracle
    libopus libsodium ffmpeg youtube-dl
  ];

  LD_LIBRARY_PATH = "${libsodium}/lib:${libopus}/lib:${oracle}/lib";

  installPhase = ''
    mkdir -p $out/{bin,share/qbot}
    cp -r * $out/share/qbot
    bin=$out/bin/qbot

    cat >$bin <<EOF
#!/bin/sh -e
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}
cd $out/share/qbot
exec ${bundler}/bin/bundle exec ${ruby_2_7}/bin/ruby $out/share/qbot/qbot "\$@"
EOF

    chmod +x $bin
  '';
}
