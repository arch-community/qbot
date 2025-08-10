{ pkgs, pkg }:

pkg.overrideAttrs (oa: {
  nativeBuildInputs =
    oa.nativeBuildInputs
    ++ (with pkgs; [
      git
      graphviz
      tokei
      (sqlite.override { interactive = true; })
      yq-go
      bundix
      cargo
      rustc
    ]);

  BUNDLE_FORCE_RUBY_PLATFORM = "1";

  LD_LIBRARY_PATH = oa.passthru.libPath;
  FONTCONFIG_FILE = oa.passthru.fontconfigFile;
})
