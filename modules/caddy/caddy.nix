{ config, ... }:

{
  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.caddy ];
  };

  modules.nixos.caddy = {
    services.caddy.enable = true;
    networking.firewall.allowedTCPPorts = [ 443 ];
  };

  modules.nixos.acme =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.services.caddy.enable {
        services.caddy = { inherit (config.security.acme.defaults) email; };
      };
    };
}
