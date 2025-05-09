{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) escapeShellArgs;

  cfg = config.services.transmission;
  settingsDir = ".config/transmission-daemon";
in

{
  sec."vopono/wireguard.conf".owner = cfg.user;

  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    webHome = pkgs.flood-for-transmission;

    group = "arr-stack";
    downloadDirPermissions = "770";
    settings = {
      download-dir = "/home/arr-stack/downloads/transmission/complete";
      incomplete-dir = "/home/arr-stack/downloads/transmission/incomplete";
      incomplete-dir-enabled = true;
      rpc-whitelist = "127.0.0.1,10.0.0.*";
      rpc-host-whitelist = "*";
      rpc-host-whitelist-enabled = true;
      ratio-limit = 0;
      ratio-limit-enabled = true;
    };
  };

  systemd.services.transmission.serviceConfig.ExecStart =
    lib.mkForce "${pkgs.writeShellScript "safe-transmission.sh" ''
      ${lib.getExe pkgs.vopono} -v exec -k -f ${toString cfg.settings.rpc-port} \
        --custom ${config.sec."vopono/wireguard.conf".path} \
        --protocol wireguard \
        "${cfg.package}/bin/transmission-daemon -f -g ${cfg.home}/${settingsDir} ${escapeShellArgs cfg.extraFlags}"
    ''}";

  services.caddy-easify.reverseProxies."http://transmission.home.local".port = cfg.settings.rpc-port;

  services.homepage-easify.categories.Dienste.services.Transmission = rec {
    icon = "transmission.svg";
    href = "http://transmission.home.local";
    siteMonitor = href;
    description = "Torrent client";
  };
}
