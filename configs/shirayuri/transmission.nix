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
    settings.download-dir = "/mnt/os-shared/Torrents";
  };

  systemd.tmpfiles.settings."10-transmission".${cfg.settings.download-dir}.d = {
    user = username;
    group = "users";
    mode = "0774";
  };
}
