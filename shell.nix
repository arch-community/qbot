{ pkgs, pkg }:

pkg.overrideAttrs (oa: {
	nativeBuildInputs = oa.nativeBuildInputs ++ (with pkgs; [
		git
		graphviz
		loc
		(sqlite.override { interactive = true; })
		yq-go
	]);

	BUNDLE_FORCE_RUBY_PLATFORM = "1";

	LD_LIBRARY_PATH = oa.passthru.libPath;
	FONTCONFIG_FILE = oa.passthru.fontconfigFile;
})
