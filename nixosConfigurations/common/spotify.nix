{
  lib,
  pkgs,
  config,
  ...
}:

let
  # String -> String
  toUppercase =
    str:
    (lib.strings.toUpper (builtins.substring 0 1 str))
    + builtins.substring 1 (builtins.stringLength str) str;

  deviceName = toUppercase config.networking.hostName;
in

{
  hm = {
    home.packages = [ pkgs.spotify-qt ];

    programs.spotify-player = {
      enable = true;

      settings = {
        client_id = "3b1a5d62ca66440db8227a697909ce1f";

        default_device = deviceName;
        device = {
          device_type = "computer";
          name = deviceName;
          bitrate = 320;
          audio_cache = true;
        };
      };
    };
  };
}
