{ pkgs ? import <nixpkgs> { config.allowUnfree = true; }
, pkg ? pkgs.callPackage ./. { } }:

pkg.overrideAttrs (oa: {
	buildInputs = oa.buildInputs ++ (with pkgs; [
		git
		graphviz
		loc
	]);

	BUNDLE_FORCE_RUBY_PLATFORM = "1";

	LD_LIBRARY_PATH = oa.passthru.libPath;
	FONTCONFIG_FILE = oa.passthru.fontconfigFile;
})
