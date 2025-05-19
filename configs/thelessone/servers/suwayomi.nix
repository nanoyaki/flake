{
  self,
  packages,
  config,
  ...
}:

let
  mkInstance = port: {
    enable = true;

    settings.server = {
      inherit port;
      extensionRepos = [
        "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"
        "https://raw.githubusercontent.com/yuzono/manga-repo/repo/index.min.json"
        "https://raw.githubusercontent.com/Kareadita/tach-extension/repo/index.min.json"
        "https://raw.githubusercontent.com/Suwayomi/tachiyomi-extension/repo/index.min.json"
      ];

      flareSolverrEnabled = true;
      flareSolverrUrl = "http://localhost:8191";
      flareSolverrSessionName = "suwayomi-${toString port}";
    };
  };

  cfg = config.services.suwayomi.instances;

  extraConfig = ''
    @outside-local not client_ip private_ranges 100.64.64.0/18 fd7a:115c:a1e0::/112
    respond @outside-local "Access Denied" 403 {
      close
    }
  '';
in

{
  imports = [
    self.nixosModules.suwayomi
  ];

  services.suwayomi = {
    enable = true;

    package = packages.suwayomi-server;

    instances = {
      thomas = mkInstance 4555;
      niklas = mkInstance 4556;
      hana = mkInstance 4557;
      mei = mkInstance 4558;
    };
  };

  services.caddy-easify.reverseProxies = {
    "https://manga.vpn.theless.one" = {
      inherit (cfg.thomas.settings.server) port;
      inherit extraConfig;
    };
    "https://nik-manga.vpn.theless.one" = {
      inherit (cfg.niklas.settings.server) port;
      inherit extraConfig;
    };
    "https://hana-manga.vpn.theless.one" = {
      inherit (cfg.hana.settings.server) port;
      inherit extraConfig;
    };
    "https://mei-manga.vpn.theless.one" = {
      inherit (cfg.mei.settings.server) port;
      inherit extraConfig;
    };
  };

  services.headscale.settings.dns.extra_records =
    map
      (name: {
        name = "${name}.vpn.theless.one";
        type = "A";
        value = "100.64.64.1";
      })
      [
        "manga"
        "nik-manga"
        "hana-manga"
        "mei-manga"
      ];

  services.homepage-easify.categories.Suwayomi = {
    layout = {
      style = "row";
      columns = 4;
    };

    services =
      let
        icon = "suwayomi-light.svg";
      in
      {
        "Thomas Suwayomi" = rec {
          description = "Thomas' suwayomi instance";
          inherit icon;
          href = "https://manga.vpn.theless.one";
          siteMonitor = href;
        };

        "Nik Suwayomi" = rec {
          description = "Nik's suwayomi instance";
          inherit icon;
          href = "https://nik-manga.vpn.theless.one";
          siteMonitor = href;
        };

        "Hana Suwayomi" = rec {
          description = "Hana's suwayomi instance";
          inherit icon;
          href = "https://hana-manga.vpn.theless.one";
          siteMonitor = href;
        };

        "Mei Suwayomi" = rec {
          description = "Meilyne's suwayomi instance";
          inherit icon;
          href = "https://mei-manga.vpn.theless.one";
          siteMonitor = href;
        };
      };
  };

  services.flaresolverr = {
    enable = true;
    port = 8191;
  };
}
