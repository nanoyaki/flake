{ config, ... }:

{
  sec."nix-serve" = { };

  services.nix-serve = {
    enable = true;
    secretKeyFile = config.sec."nix-serve".path;
  };

  services'.caddy.reverseProxies."cache.vpn.theless.one" = {
    inherit (config.services.nix-serve) port;
    vpnOnly = true;
  };
}
