{
  pkgs,
  ...
}:

let
  nwjs = pkgs.nwjs.override { alsa-lib = pkgs.alsa-lib-with-plugins; };

  nwjs-run = pkgs.writeShellScriptBin "nwjs-run" ''
    LD_PRELOAD=${pkgs.nwjs-ffmpeg-prebuilt}/lib/libffmpeg.so ${nwjs}/bin/nw "$@"
  '';
in

{
  environment.systemPackages = [
    nwjs-run
  ];
}
