{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

(pkgs.callPackage ./. { }).overrideAttrs (oa: {
	buildInputs = oa.buildInputs ++ (with pkgs; [
		git
		graphviz
		loc
	]);

	BUNDLE_FORCE_RUBY_PLATFORM = "1";
})
