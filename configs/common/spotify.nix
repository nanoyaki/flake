{
  lib,
  lib',
  pkgs,
  config,
  ...
}:

let
  inherit (lib') toUppercase;

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

    # for spotify-qt to always find librespot
    home.file.".local/bin/librespot".source = lib.getExe pkgs.librespot;
  };

  systemd.user.services.librespot = {
    enable = true;
    description = "Librespot";

    unitConfig.ConditionUser = "!root";

    script = ''
      ${lib.getExe pkgs.librespot} --username "aex77xiuiva5s17odjzngj6jb" \
        --cache $XDG_CACHE_HOME/librespot \
        --enable-oauth \
        --name "${deviceName}" \
        --bitrate 320 \
        --device-type "computer"
    '';

    serviceConfig = {
      Restart = "no";
      Type = "simple";
    };

    wantedBy = [ "default.target" ];
  };
}
