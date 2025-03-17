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

  hm = {
    xdg.desktopEntries.librespot = {
      name = "Librespot";
      comment = "The spotify background process";
      exec = lib.getExe (
        pkgs.writeSystemdToggle.override {
          service = "librespot";
          isUserService = true;
        }
      );
      icon = "${pkgs.catppuccin-papirus-folders}/share/icons/Papirus/64x64/apps/spotify.svg";
      categories = [
        "AudioVideo"
        "Audio"
        "Music"
      ];
      terminal = false;
    };

    # for spotify-qt to always find librespot
    home.file.".local/share/librespot/binary".source = lib.getExe pkgs.librespot;
    home.packages = [ pkgs.spotify-qt ];
  };
}
