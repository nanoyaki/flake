{ config, ... }:

{
  sec."nix-serve" = { };

  services.nix-serve = {
    enable = true;
    secretKeyFile = config.sec."nix-serve".path;
  };

  services.caddy-easify.reverseProxies."cache.theless.one" = {
    inherit (config.services.nix-serve) port;
    extraConfig = ''
      @outside-local not client_ip private_ranges 100.64.64.0/18 fd7a:115c:a1e0::/112
      respond @outside-local "Access Denied" 403 {
        close
      }
    '';
  };
}
