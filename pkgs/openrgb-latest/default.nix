{
  lib,
  openrgb,
  coreutils,

  _sources,
}:

openrgb.overrideAttrs {
  inherit (_sources.openrgb) version src;

  postPatch = ''
    patchShebangs scripts/build-udev-rules.sh
    substituteInPlace scripts/build-udev-rules.sh \
      --replace-fail "/usr/bin/env chmod" "${lib.getExe' coreutils "chmod"}"
  '';
}
