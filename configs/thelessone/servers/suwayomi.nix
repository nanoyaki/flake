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
    };
  };

  cfg = config.services.suwayomi.instances;
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
    };
  };

  services.caddy-easify.reverseProxies = {
    "manga.theless.one" = {
      inherit (cfg.thomas.settings.server) port;
      userEnvVar = "thelessone";
    };
    "nik-manga.theless.one" = {
      inherit (cfg.niklas.settings.server) port;
      userEnvVar = "nik";
    };
    "hana-manga.theless.one" = {
      inherit (cfg.hana.settings.server) port;
      userEnvVar = "hana";
    };
  };

  services.homepage-easify.categories.Suwayomi = {
    layout = {
      style = "row";
      columns = 3;
    };

    services =
      let
        icon = "suwayomi-light.svg";
      in
      {
        "Thomas Suwayomi" = rec {
          description = "Thomas' suwayomi manga reading instance";
          inherit icon;
          href = "https://manga.theless.one";
          siteMonitor = href;
        };

        "Nik Suwayomi" = rec {
          description = "Nik's suwayomi manga reading instance";
          inherit icon;
          href = "https://nik-manga.theless.one";
          siteMonitor = href;
        };

        "Hana Suwayomi" = rec {
          description = "Hana's suwayomi manga reading instance";
          inherit icon;
          href = "https://hana-manga.theless.one";
          siteMonitor = href;
        };
      };
  };
}
