{
  pkgs,
  config,
  ...
}:

let
  cfg = config.services.transmission;
in

{
  services.transmission = {
    enable = true;

    webHome = pkgs.flood-for-transmission;
    downloadDirPermissions = "775";
    settings = {
      download-dir = "/mnt/os-shared/Torrents";
      rpc-port = 9091;
    };
  };

  systemd.tmpfiles.settings."10-transmission".${cfg.settings.download-dir}.d = {
    inherit (cfg) user group;
    mode = "0${cfg.downloadDirPermissions}";
  };

  services.mullvad-vpn.enable = true;
}
