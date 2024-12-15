{self, ...}:{
  desktop = (final: prev: {
    # Inkscape crashes on wayland when a tablet is connected.
    # https://gitlab.com/inkscape/inkscape/-/issues/4649
    inkscape = prev.pkgs.symlinkJoin {
      name = "inkscape";
      paths = [prev.inkscape];
      buildInputs = [prev.pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/inkscape \
          --unset WAYLAND_DISPLAY
      '';
    };
    arduino-core-unwrapped = prev.arduino-core-unwrapped.overrideAttrs (finalAttrs: prevAttrs: {
      installPhase = prevAttrs.installPhase + ''
        wrapProgram $out/bin/arduino \
          --set _JAVA_AWT_WM_NONREPARENTING 1
      '';
    });
    # I like using the newest features of Kicad, and they tend to trickle down to stable a little
    # slowly
    #kicad = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.kicad;
    # As of this commit, PrismLauncher doesn't work right with the stable version.  Some login
    # issues. Check this later and roll back when it makes sense
    prismlauncher = self.inputs.nixpkgs-unstable.legacyPackages.${final.system}.prismlauncher;
    firefoxpwa = self.inputs.nixpkgs-unstable.legacyPackages.${final.system}.firefoxpwa;
  });
}
