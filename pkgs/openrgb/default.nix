{
  lib,
  openrgb,
  fetchFromGitHub,
  coreutils,
}:

openrgb.overrideAttrs rec {
  version = "45af044cd84032b9a9b5865cb5e12aa2cd98c47e";
  src = fetchFromGitHub {
    owner = "CalcProgrammer1";
    repo = "OpenRGB";
    rev = version;
    hash = "sha256-3zOlL2HdZ+6o9pkB03R7BTWcM9lQh9DgKoIbFEUmbxU=";
  };

  postPatch = ''
    patchShebangs scripts/build-udev-rules.sh
    substituteInPlace scripts/build-udev-rules.sh \
      --replace-fail "/usr/bin/env chmod" "${lib.getExe' coreutils "chmod"}"
  '';
}
