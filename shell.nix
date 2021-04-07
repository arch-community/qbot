let
  pkgs = (import <nixpkgs> { config.allowUnfree = true; });
in
  pkgs.callPackage ./. { }
