{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

(pkgs.callPackage ./. { }).overrideAttrs (oa: {
	buildInputs = oa.buildInputs ++ (with pkgs; [
		graphviz
		loc
	]);
})
