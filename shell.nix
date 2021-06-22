let
  pkgs = (import <nixpkgs> { config.allowUnfree = true; });
in
  (pkgs.callPackage ./. { }).overrideAttrs (oa: {
    buildInputs = oa.buildInputs ++ (with pkgs; [
      graphviz
    ]);
  })
