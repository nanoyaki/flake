{ config, ... }:

{
  imports = [
    ../../../modules/dynamicdns
  ];

  sec = {
    "dynamicdns/nanoyaki.space".owner = config.services.namecheapDynDns.user;
    "dynamicdns/theless.one".owner = config.services.namecheapDynDns.user;
  };

  services.namecheapDynDns = {
    enable = true;

    domains = {
      "nanoyaki.space" = {
        subdomains = [
          "*"
          "@"
        ];

        passwordFile = config.sec."dynamicdns/nanoyaki.space".path;
      };

      "theless.one" = {
        subdomains = [
          "*"
          "@"
        ];

        passwordFile = config.sec."dynamicdns/theless.one".path;
      };
    };
  };
}
