{ lib', ... }:

lib'.modules.mkModule {
  name = "flaresolverr";

  config =
    { cfg, helpers', ... }:

    {
      services.flaresolverr = {
        enable = true;
        port = helpers'.defaultPort cfg 8191;
        inherit (cfg) openFirewall;
      };
    };

  dependencies = [ "firewall" ];
}
