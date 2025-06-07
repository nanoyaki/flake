{ lib, config, ... }:

let
  cfg = config.services.stash;
in

{
  sec = lib.genAttrs [ "stash/password" "stash/jwtSecret" "stash/sessionStoreSecret" ] (_: {
    owner = cfg.user;
  });

  services.stash = {
    enable = true;

    passwordFile = config.sec."stash/password".path;
    jwtSecretKeyFile = config.sec."stash/jwtSecret".path;
    sessionStoreKeyFile = config.sec."stash/sessionStoreSecret".path;

    username = "admin";
    mutableSettings = true;
    settings = {
      host = "127.0.0.1";
      stash = [
        {
          path = "/mnt/raid/arr-stack/libraries/anime/adult";
        }
        {
          path = "/mnt/raid/arr-stack/libraries/adult";
        }
      ];
    };
  };

  services'.caddy.reverseProxies."https://stash.vpn.theless.one" = {
    inherit (cfg.settings) port;
    vpnOnly = true;
  };

  services'.homepage.categories.Media.services.Stash = rec {
    description = "Adult video server";
    icon = "stash.svg";
    href = "https://stash.vpn.theless.one";
    siteMonitor = href;
  };
}
