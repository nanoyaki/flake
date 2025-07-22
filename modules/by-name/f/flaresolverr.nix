{
  lib,
  lib',
  config,
  ...
}:

{
  options.config'.flaresolverr.enable = lib'.options.mkFalseOption;

  config = lib.mkIf config.config'.flaresolverr.enable {
    config'.vopono.allowedTCPPorts = [ config.services.flaresolverr.port ];

    services.flaresolverr = {
      enable = true;
      port = 8191;
    };
  };
}
