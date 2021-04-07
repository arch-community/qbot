{ stdenv, lib, symlinkJoin, makeWrapper
, pkg-config, git
, ruby_3_0, bundler, bundix, defaultGemConfig, bundlerApp
, libsodium, libopus, ffmpeg, youtube-dl
, sqlite, zlib, shared-mime-info, libxml2, libiconv
, figlet }:

let
  ruby' = ruby_3_0;
in bundlerApp rec {
  pname = "qbot";

  gemdir = ./.;
  
  gemfile  = ./Gemfile;
  lockfile = ./Gemfile.lock;
  gemset   = ./gemset.nix;

  exes = [ "qbot" ];

  ruby = ruby';

  gemConfig = defaultGemConfig // {
    nokogiri = attrs: {
      buildInputs = [ pkg-config zlib.dev ];
    };
    mimemagic = attrs: {
      FREEDESKTOP_MIME_TYPES_PATH = "${shared-mime-info}/share/mime/packages/freedesktop.org.xml";
    };
  };

  buildInputs = [
    sqlite libxml2 zlib.dev zlib libiconv
    libopus libsodium ffmpeg youtube-dl
    figlet
    git bundix
    makeWrapper
  ];

  postBuild = ''
    wrapProgram $out/bin/qbot \
      --set LD_LIBRARY_PATH "${lib.makeLibraryPath [ libsodium libopus ]}"
      --set FLF_DIR "${figlet}/share/figlet\'
  '';
}
