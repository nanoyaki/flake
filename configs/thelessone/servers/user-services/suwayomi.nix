{
  config,
  pkgs,
  ...
}:

let
  mkInstance = port: {
    enable = true;

    settings.server = {
      inherit port;
      extensionRepos = map (repo: "https://raw.githubusercontent.com/${repo}/repo/index.min.json") [
        "keiyoushi/extensions"
        "yuzono/manga-repo"
        "Kareadita/tach-extension"
        "Suwayomi/tachiyomi-extension"
      ];

      flareSolverrEnabled = true;
      flareSolverrUrl = "http://localhost:8191";
      flareSolverrSessionName = "suwayomi-${toString port}";
    };
  };

  icon = "suwayomi-light.svg";
  cfg = config.services.suwayomi.instances;
in

{
  services.suwayomi = {
    enable = true;

    package = pkgs.suwayomi-server;

    instances = {
      thomas = mkInstance 4555;
      niklas = mkInstance 4556;
      hana = mkInstance 4557;
      mei = mkInstance 4558;
    };
  };

  config'.caddy.reverseProxies = {
    "https://manga.theless.one" = {
      inherit (cfg.thomas.settings.server) port;
      extraConfig = config.config'.mtls.caddySnippet;
    };
    "https://nik-manga.theless.one" = {
      inherit (cfg.niklas.settings.server) port;
      extraConfig = config.config'.mtls.caddySnippet;
    };
    "https://hana-manga.theless.one" = {
      inherit (cfg.hana.settings.server) port;
      extraConfig = config.config'.mtls.caddySnippet;
    };
    "https://mei-manga.theless.one" = {
      inherit (cfg.mei.settings.server) port;
      extraConfig = config.config'.mtls.caddySnippet;
    };
  };

  config'.homepage.categories.Suwayomi = {
    layout = {
      style = "row";
      columns = 4;
    };

    services = {
      "Thomas Suwayomi" = rec {
        description = "Thomas' suwayomi instance";
        inherit icon;
        href = "https://manga.theless.one";
        siteMonitor = href;
      };

      "Nik Suwayomi" = rec {
        description = "Nik's suwayomi instance";
        inherit icon;
        href = "https://nik-manga.theless.one";
        siteMonitor = href;
      };

      "Hana Suwayomi" = rec {
        description = "Hana's suwayomi instance";
        inherit icon;
        href = "https://hana-manga.theless.one";
        siteMonitor = href;
      };

      "Mei Suwayomi" = rec {
        description = "Meilyne's suwayomi instance";
        inherit icon;
        href = "https://mei-manga.theless.one";
        siteMonitor = href;
      };
    };
  };
}
