{
  lib,
  stdenvNoCC,
  findutils,

  background ? "1E2127FF",
  background-alt ? "282B31FF",
  foreground ? "FFFFFFFF",
  selected ? "61AFEFFF",
  active ? "98C379FF",
  urgent ? "E06C75FF",

  _sources,
}:

stdenvNoCC.mkDerivation {
  inherit (_sources.rofi-themes) pname version src;

  patchPhase = ''
    runHook prePatch

    for rasiFile in $(${lib.getExe findutils} . -name "*.rasi"); do
      substituteInPlace $rasiFile \
        --replace-quiet "@background" "#${background}" \
        --replace-quiet "@background-alt" "#${background-alt}" \
        --replace-quiet "@foreground" "#${foreground}" \
        --replace-quiet "@selected" "#${selected}" \
        --replace-quiet "@active" "#${active}" \
        --replace-quiet "@urgent" "#${urgent}" \
        --replace-quiet "@import                          \"shared/colors.rasi\"" ""
    done

    runHook postPatch
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/themes
    cp -r files/* $out/share/themes

    runHook postInstall
  '';
}
