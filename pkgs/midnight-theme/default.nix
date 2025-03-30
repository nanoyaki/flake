{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "midnight-theme";
  version = "c32b4cca12962ea95b518b8f9b76cfdfbe31f6ad";

  src = fetchFromGitHub {
    owner = "refact0r";
    repo = "midnight-discord";
    rev = "c32b4cca12962ea95b518b8f9b76cfdfbe31f6ad";
    hash = "sha256-gVAHS7uBsB+IDh1sNcvIRmKSLI94txeC9vCBXwZCjq0=";
  };

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
