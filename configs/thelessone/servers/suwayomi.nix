{
  self,
  lib',
}:

lib'.modules.mkModule {
  name = "suwayomi-server";

  imports = [
    self.nixosModules.suwayomi
  ];

  config =
    { config, pkgs, ... }:

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
    in

    {
      nixpkgs.overlays = [
        (_: prev: {
          suwayomi-server = prev.suwayomi-server.overrideAttrs (prevAttrs: {
            gradleFlags = (prevAttrs.gradleFlags or [ ]) ++ [
              "-Dkotlin.daemon.jvmargs=-Xmx4096m"
              "-Dorg.gradle.jvmargs=-Xmx5120m"
              "-Dkotlin.compiler.execution.strategy=in-process"
            ];
          });
        })
      ];

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

      services'.caddy.reverseProxies = {
        "https://manga.vpn.theless.one" = {
          inherit (cfg.thomas.settings.server) port;
          vpnOnly = true;
        };
        "https://nik-manga.vpn.theless.one" = {
          inherit (cfg.niklas.settings.server) port;
          vpnOnly = true;
        };
        "https://hana-manga.vpn.theless.one" = {
          inherit (cfg.hana.settings.server) port;
          vpnOnly = true;
        };
        "https://mei-manga.vpn.theless.one" = {
          inherit (cfg.mei.settings.server) port;
          vpnOnly = true;
        };
      };

      services'.homepage.categories.Suwayomi = {
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
    };
}
