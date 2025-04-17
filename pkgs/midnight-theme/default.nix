{
  lib,
  stdenvNoCC,
  _sources,
}:

stdenvNoCC.mkDerivation {
  inherit (_sources.midnight-theme) pname version src;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r themes $out/share

    runHook postInstall
  '';

  meta = {
    description = "Dark, customizable discord theme";
    homepage = "https://github.com/refact0r/midnight-discord";
    license = lib.licenses.mit;
  };
}
