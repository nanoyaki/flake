{ pkgs, ... }:

{
  services.caddy = {
    enable = true;
    email = "hanakretzer@gmail.com";

    logFormat = ''
      format console
      level INFO
    '';

    virtualHosts = {
      "home.lan".extraConfig = ''
        tls internal
        reverse_proxy localhost:8082
      '';

      "homeassistant.home.lan".extraConfig = ''
        tls internal
        reverse_proxy localhost:8123
      '';
    };
  };

  systemd.services.caddy.path = [ pkgs.nssTools ];
}
