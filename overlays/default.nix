{...}:{
  arduino = (final: prev: {
    arduino = prev.arduino.overrideAttrs (old: {
      buildInputs = old.buildInputs or [] ++ [ final.makeWrapper ];
      postInstall = old.postInstall or "" + ''
        wrapProgram "$out/bin/arduino" --set _JAVA_AWT_WM_NONREPARENTING 1
      '';
    });
  });
}
