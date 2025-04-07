{ pkgs, ... }:

let
  mkNonNixosProton =
    pkg: steamDisplayName:
    pkg.overrideAttrs (oldAttrs: {
      outputs = [ "out" ];

      installPhase = ''
        runHook preInstall

        mkdir $out
        ln -s $src/* $out
        rm $out/compatibilitytool.vdf
        cp $src/compatibilitytool.vdf $out

        runHook postInstall
      '';

      preFixup = ''
        substituteInPlace "$out/compatibilitytool.vdf" \
          --replace-fail "${oldAttrs.version}" "${steamDisplayName}"
      '';
    });
in

{
  home.file.".steam/debian-installation/compatibilitytools.d/Proton-GE".source =
    mkNonNixosProton pkgs.proton-ge-bin "Proton GE";

  home.file.".steam/debian-installation/compatibilitytools.d/Proton-GE-rtsp".source =
    mkNonNixosProton pkgs.proton-ge-rtsp-bin "Proton GE rtsp";
}
