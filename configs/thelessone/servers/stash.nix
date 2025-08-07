{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.services.stash;
in

{
  sops.secrets = lib.genAttrs [ "stash/password" "stash/jwtSecret" "stash/sessionStoreSecret" ] (_: {
    owner = cfg.user;
  });

  services.stash = {
    enable = true;

    group = "arr-stack";
    passwordFile = config.sops.secrets."stash/password".path;
    jwtSecretKeyFile = config.sops.secrets."stash/jwtSecret".path;
    sessionStoreKeyFile = config.sops.secrets."stash/sessionStoreSecret".path;

    mutablePlugins = true;
    mutableScrapers = true;

    username = "administrator";
    mutableSettings = true;
    settings = {
      host = "127.0.0.1";
      stash = [
        {
          path = "/mnt/raid/arr-stack/libraries/anime/hentai";
        }
        {
          path = "/mnt/raid/arr-stack/libraries/adult";
        }
      ];
    };
  };

  systemd.services.stash = {
    requires = [ "mnt-raid.mount" ];
    after = [ "mnt-raid.mount" ];
    bindsTo = [ "mnt-raid.mount" ];
  };

  environment.systemPackages = [ pkgs.chromium ];

  config'.caddy.reverseProxies."https://stash.vpn.theless.one" = {
    inherit (cfg.settings) port;
    vpnOnly = true;
  };

  config'.homepage.categories.Media.services.Stash = rec {
    description = "Adult video server";
    icon = "stash.svg";
    href = "https://stash.vpn.theless.one";
    siteMonitor = href;
  };
}
