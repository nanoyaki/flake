{
  pkgs,
  ...
}:

let
  nwjs-run = (
    pkgs.writeShellScriptBin "nwjs-run" ''
      LD_PRELOAD=${pkgs.nwjs-ffmpeg-prebuilt}/lib/libffmpeg.so ${pkgs.nwjs}/bin/nw "$@"
    ''
  );
in

{
  environment.systemPackages = [
    nwjs-run
  ];
}
