{ lib', ... }:

lib'.modules.mkModule {
  name = "flaresolverr";

  config =
    {
      cfg,
      config,
      helpers',
      ...
    }:

    {
      services'.vopono.allowedTCPPorts = [ config.services.flaresolverr.port ];

      services.flaresolverr = {
        enable = true;
        port = helpers'.firewall.defaultPort cfg 8191;
        inherit (cfg) openFirewall;
      };
    };

  dependencies = [ "firewall" ];
}
