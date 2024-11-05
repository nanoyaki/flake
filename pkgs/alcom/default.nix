{
  lib,
  fetchurl,
  appimageTools,
}:

appimageTools.wrapType2 rec {
  pname = "alcom";
  version = "0.1.16-beta.2";

  src = fetchurl {
    url = "https://github.com/vrc-get/vrc-get/releases/download/gui-v${version}/alcom-${version}-x86_64.AppImage";
    hash = "sha256-in3Ci6p9LuGrRHwTVz7BmOY3cRNjNvV6tMXBasQ+cig=";
  };

  meta = {
    description = "Open Source command line client of VRChat Package Manager, the main feature of VRChat Creator Companion (VCC), which supports Windows, Linux, and macOS.";
    homepage = "https://github.com/vrc-get/vrc-get";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "alcom";
    platforms = lib.platforms.x86_64;
  };
}
