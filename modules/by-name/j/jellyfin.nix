{
  lib,
  lib',
  config,
  ...
}:

let
  inherit (lib) genAttrs mkIf;
  inherit (lib'.options)
    mkDefault
    mkListOf
    mkStrOption
    mkPathOption
    mkFalseOption
    ;

  inherit (config.config'.lab-config) arr;
  inherit (arr) home;

  cfg = config.config'.jellyfin;
  domain = config.config'.caddy.genDomain cfg.subdomain;
in

{
  options.config'.jellyfin = {
    enable = mkFalseOption;

    subdomain = mkDefault "jellyfin" mkStrOption;

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

  config = mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      inherit (arr) group;
    };

    config'.caddy.reverseProxies.${domain}.port = 8096;

    config'.homepage.categories.${cfg.homepage.category}.services.Jellyfin = {
      icon = "jellyfin.svg";
      href = domain;
      siteMonitor = domain;
      inherit (cfg.homepage) description;
    };

    systemd.tmpfiles.settings."10-jelyfin" = genAttrs cfg.libraryDirectories (_: {
      d = {
        inherit (config.services.jellyfin) user;
        inherit (arr) group;
        mode = "2770";
      };
    });

    users.users.${config.services.jellyfin.user}.extraGroups = [ "render" ];
  };
}
