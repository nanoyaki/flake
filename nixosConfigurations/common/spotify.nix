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
in

{
  hm.home.packages = [ pkgs.spotify-qt ];

  systemd.user.services.librespot = {
    enable = true;
    description = "Librespot";

    unitConfig.ConditionUser = "!root";

    script = ''
      ${lib.getExe pkgs.librespot} --username "aex77xiuiva5s17odjzngj6jb" \
        --cache $XDG_CACHE_HOME/librespot \
        --enable-oauth \
        --name "${toUppercase config.networking.hostName}" \
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
