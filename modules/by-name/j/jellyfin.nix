{
  lib,
  lib',
  ...
}:

let
  inherit (lib) genAttrs;
  inherit (lib'.options)
    mkDefault
    mkListOf
    mkStrOption
    mkPathOption
    ;
in

lib'.modules.mkModule {
  name = "jellyfin";

  options =
    { cfg', ... }:

    let
      inherit (cfg'.lab-config.arr) home;
    in

    {
      libraryDirectories = mkDefault [
        "${home}/libraries/movies"
        "${home}/libraries/shows"
        "${home}/libraries/music"
        "${home}/libraries/anime/movies"
        "${home}/libraries/anime/shows"
        "${home}/libraries/anime/adult"
      ] (mkListOf mkPathOption);

      homepage = {
        category = mkDefault "Media" mkStrOption;
        description = mkDefault "Movie and show archive" mkStrOption;
      };
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
      services.jellyfin = {
        enable = true;
        inherit (cfg'.lab-config.arr) group;
      };

      services'.caddy.reverseProxies.${domain}.port = 8096;

      services'.homepage.categories.${cfg.homepage.category}.services.Jellyfin = {
        icon = "jellyfin.svg";
        href = domain;
        siteMonitor = domain;
        inherit (cfg.homepage) description;
      };

      systemd.tmpfiles.settings."10-jelyfin" = genAttrs cfg.libraryDirectories (_: {
        d = {
          inherit (config.services.jellyfin) user;
          inherit (cfg'.lab-config.arr) group;
          mode = "2770";
        };
      });
    };

  dependencies = [
    "caddy"
    "homepage"
    "lab-config"
  ];
}
