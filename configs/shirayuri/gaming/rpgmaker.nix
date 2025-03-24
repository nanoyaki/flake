{
  lib,
  pkgs,
  ...
}:

let
  nwjs = pkgs.nwjs.override { alsa-lib = pkgs.alsa-lib-with-plugins; };

  nwjs-run = pkgs.writeShellScriptBin "nwjs-run" ''
    ${lib.getExe' pkgs.coreutils "cat"} <<< $(${lib.getExe pkgs.jq} 'def n: if . == "" then "{}" else . end; .name = (.name|n)' package.json) > package.json
    LD_PRELOAD=${pkgs.nwjs-ffmpeg-prebuilt}/lib/libffmpeg.so ${lib.getExe' nwjs "nw"} "$@"
  '';
in

{
  environment.systemPackages = [ nwjs-run ];
}
