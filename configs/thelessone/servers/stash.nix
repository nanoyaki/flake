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
  sops.secrets =
    lib.genAttrs
      [
        "stash/password"
        "stash/jwtSecret"
        "stash/sessionStoreSecret"
        "stash/shoko/user"
        "stash/shoko/pass"
      ]
      (_: {
        owner = cfg.user;
      });

  sops.templates."config.json".file = (pkgs.formats.json { }).generate "config.json.template" {
    url = "https://shoko.vpn.theless.one";
    user = config.sops.placeholder."stash/shoko/user";
    pass = config.sops.placeholder."stash/shoko/pass";
  };

  services.stash = {
    enable = true;

    group = "arr-stack";
    passwordFile = config.sops.secrets."stash/password".path;
    jwtSecretKeyFile = config.sops.secrets."stash/jwtSecret".path;
    sessionStoreKeyFile = config.sops.secrets."stash/sessionStoreSecret".path;

    mutablePlugins = true;
    scrapers = with pkgs.stashScrapers; [
      (shokoApi.override {
        configJSON = config.sops.templates."config.json".path;
      })
      aniDb
      hanime
    ];

    username = "administrator";
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
      python_path = toString (
        pkgs.python313.withPackages (
          pyPkgs: with pyPkgs; [
            requests
          ]
        )
      );
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
