with (import <nixpkgs> { overlays = [(self: super: { ruby = super.ruby_2_7; })]; config.allowUnfree = true; });
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
    inherit ruby;
    gemfile  = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset   = ./gemset.nix;
    gemdir   = ./.;
    gemConfig = pkgs.defaultGemConfig // {
      ruby-oci8 = attrs: {
        LD_LIBRARY_PATH = "${oracle}/lib";
      };
    };
  };
in stdenv.mkDerivation rec {
  name = "qbot";

  src = ./.;

  buildInputs = [
    env.wrappedRuby bundler bundix
    git
    sqlite libxml2 zlib
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
exec ${bundler}/bin/bundle exec ${ruby_2_7}/bin/ruby $out/share/qbot/qbot "\$@"
EOF

    chmod +x $bin
  '';
}
