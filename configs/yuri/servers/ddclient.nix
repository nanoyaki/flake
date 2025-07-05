{ config, ... }:

{
  sec = {
    "porkbun/api-key" = { };
    "porkbun/secret-api-key" = { };
  };

  sops.templates."ddclient.conf" = {
    content = ''
      daemon=600
      use=if
      ipv6=true
      ipv4=false

      protocol=porkbun
      apikey=${config.sops.placeholder."porkbun/api-key"}
      secretapikey=${config.sops.placeholder."porkbun/secret-api-key"}
      nanoyaki.space,events.nanoyaki.space
    '';
  };

  services.ddclient = {
    enable = true;
    configFile = config.sops.templates."ddclient.conf".path;
  };
}
