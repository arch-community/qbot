with (import <nixpkgs> { overlays = [(self: super: { ruby = super.ruby_2_7; })]; });
let
  oracle = symlinkJoin {
    name = "instantclient";
    paths = with oracle-instantclient; [ oracle-instantclient lib dev ];
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
    gemConfig = pkgs.defaultGemConfig // {
      ruby-oci8 = attrs: {
        LD_LIBRARY_PATH = "${oracle}/lib";
      };
    };
  };
in stdenv.mkDerivation {
  name = "qbot";

  src = ./.;

  buildInputs = [
    ruby_2_7 env bundler bundix
    git
    sqlite libxml2 zlib
    oracle-instantclient oracle
    libopus libsodium ffmpeg youtube-dl
  ];

  LD_LIBRARY_PATH = "${libsodium}/lib:${libopus}/lib:${oracle}/lib";
  BUNDLE_BUILD__RUBY-OCI8 = "--with-instant-client-include=${oracle}/include";

  installPhase = ''
    mkdir -p $out/{bin,share/qbot}
    cp -r * $out/share/qbot
    bin=$out/bin/qbot

    cat >$bin <<EOF
#!/bin/sh -e
exec ${bundler}/bin/bundle exec ${ruby_2_7}/bin/ruby $i "\$@"
EOF

    chmod +x $bin
  '';
}
