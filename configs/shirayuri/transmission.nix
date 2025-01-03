{
  pkgs,
  username,
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
    settings = {
      download-dir = "/mnt/os-shared/Torrents";
      rpc-port = 9091;
    };
  };

  systemd.tmpfiles.settings."10-transmission".${cfg.settings.download-dir}.d = {
    user = username;
    group = "users";
    mode = "0774";
  };

  services.mullvad-vpn.enable = true;
}
