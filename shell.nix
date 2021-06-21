let
  pkgs = (import <nixpkgs> { config.allowUnfree = true; });
  myBundler = pkgs.callPackage ./bundler-2.2.20.nix { };
in
  pkgs.callPackage ./. { bundler = myBundler; }
