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
        reverse_proxy localhost:8082
      '';

      "homeassistant.home.lan".extraConfig = ''
        reverse_proxy localhost:8123
      '';
    };
  };
}
