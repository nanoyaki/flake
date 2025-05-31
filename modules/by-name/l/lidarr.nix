{
  lib,
  lib',
  ...
}:

let
  inherit (lib'.options)
    mkDefault
    mkStrOption
    ;
  inherit (lib) optionalAttrs versionOlder;
in

lib'.modules.mkModule {
  name = "lidarr";

  options.homepage = {
    category = mkDefault "Media services" mkStrOption;
    description = mkDefault "Music manager" mkStrOption;
  };

  config =
    {
      cfg,
      cfg',
      config,
      helpers',
      ...
    }:

    let
      domain = helpers'.caddy.domain cfg;
    in

    {
      nixpkgs.overlays = [
        (
          final: prev:
          let
            version = "2.11.2.4629";
          in
          {
            lidarr = prev.lidarr.overrideAttrs (
              optionalAttrs (versionOlder prev.lidarr.version version) {
                inherit version;
                src = final.fetchurl {
                  url = "https://github.com/lidarr/Lidarr/releases/download/v${version}/Lidarr.master.${version}.linux-core-x64.tar.gz";
                  sha256 = "sha256-QHCHB7ep23nd8YAF3klzvAd9ZNkCTI9P2pELQwmsrDw=";
                };
              }
            );
          }
        )
      ];

      services'.vopono.allowedTCPPorts = [ config.services.lidarr.settings.server.port ];

      services.lidarr = {
        enable = true;
        inherit (cfg'.lab-config.arr) group;
      };

      services'.caddy.reverseProxies.${domain} = {
        inherit (config.services.lidarr.settings.server) port;
      };

      services'.homepage.categories.${cfg.homepage.category}.services.Lidarr = {
        icon = "lidarr.svg";
        href = domain;
        siteMonitor = domain;
        inherit (cfg.homepage) description;
      };
    };

  dependencies = [
    "caddy"
    "homepage"
    "lab-config"
  ];
}
