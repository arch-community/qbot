{
  stdenv,
  lib,
  makeWrapper,
  fetchFromGitHub,
  gitignoreSource,
  ruby,
  bundler,
  bundix,
  pkg-config,
  bundlerEnv,
  defaultGemConfig,
  rustPlatform,
  cargo,
  rustc,
  fetchgit,
  libsodium,
  libopus,
  imagemagick,
}:

let
  env = bundlerEnv {
    name = "qbot-bundler-env";
    gemdir = ./.;
    inherit ruby;

    gemConfig = defaultGemConfig // {
      tantiny = attrs: {
        cargoDeps = rustPlatform.fetchCargoVendor {
          src = fetchgit {
            inherit (attrs.source)
              url
              rev
              sha256
              fetchSubmodules
              ;
          };

          hash = "sha256-8/19wvSXhVxIYQ6KxXKgIjNaAWBXDuSBReZq1i48niY=";
        };

        nativeBuildInputs = [
          rustPlatform.cargoSetupHook
          cargo
          rustc
        ];

        postUnpack = ''
          mv .cargo tantiny*
        '';

        # ruby3.2-tantiny-0efa1bf> ERROR: noBrokenSymlinks: the symlink /nix/store/v3w3kzq8cpl571r88adlzyng8wb5rcp6-ruby3.2-tantiny-0efa1bf19104/lib/ruby/gems/3.2.0/bundler/gems/tantiny-0efa1bf19104/target/release/deps/libruby.so.3.2 points to a missing target: /nix/store/vx12063b4lpgslgrydiaak2a9240f8dm-ruby-3.2.8/lib/libruby.so.3.2
        postFixup = ''
          rm $out/lib/ruby/gems/${ruby.passthru.version.libDir}/bundler/gems/tantiny-*/target/release/deps/libruby.so.${ruby.passthru.version.majMin}
          ln -s ${lib.getLib ruby}/lib/libruby-${ruby.passthru.version.majMinTiny}.so $out/lib/ruby/gems/${ruby.passthru.version.libDir}/bundler/gems/tantiny-*/target/release/deps/libruby.so.${ruby.passthru.version.majMin}
        '';
      };
    };
  };

in
stdenv.mkDerivation rec {
  name = "qbot";

  src = gitignoreSource ./.;

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];
  buildInputs = [
    env.wrappedRuby
    imagemagick
  ];
  propagatedBuildInputs = [
    libopus
    libsodium
  ];

  passthru = {
    fontconfigFile = "${src}/share/fc-config.xml";
    binPath = lib.makeBinPath buildInputs;
    libPath = lib.makeLibraryPath propagatedBuildInputs;
  };

  installPhase =
    let
      inherit (passthru) binPath libPath fontconfigFile;
    in
    ''
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
