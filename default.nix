with (import <nixpkgs> {});
let
  bundler' = bundler.override {
    ruby = ruby_2_7;
  };
  bundlerEnv' = bundlerEnv.override {
    bundler = bundler';
  };
  env = bundlerEnv' {
    name = "qbot-bundler-env";
    inherit ruby_2_7;
    gemfile  = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset   = ./gemset.nix;
  };
in stdenv.mkDerivation {
  name = "qbot";
  src = ./.;
  buildInputs = [ ruby_2_7 env bundler' (bundix.override { bundler = bundler'; }) sqlite ];
  installPhase = ''
    mkdir -p $out/bin
  '';
}
