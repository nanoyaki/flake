{
  lib,
  pkgs,
  ...
}:

{
  nixpkgs.overlays = [
    (final: prev: {
      nwjs = prev.nwjs.override { alsa-lib = final.alsa-lib-with-plugins; };
      nwjs-run = final.writeShellScriptBin "nwjs-run" ''
        QUERY='def n: if . == "" then "{}" else . end; .name = (.name|n)'

        ${lib.getExe' final.coreutils "cat"} <<< $(${lib.getExe final.jq} "$QUERY" package.json) > package.json
        LD_PRELOAD=${final.nwjs-ffmpeg-prebuilt}/lib/libffmpeg.so ${lib.getExe' final.nwjs "nw"} "$@"
      '';
    })
  ];

  environment.systemPackages = [ pkgs.nwjs-run ];
}
