{ config, self, ... }:

{
  imports = [
    self.nixosModules.dynamicdns
  ];

  sec = {
    "dynamicdns/nanoyaki.space" = { };
    "dynamicdns/theless.one" = { };
    "dynamicdns/vappie.space" = { };
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

      "vappie.space" = {
        subdomains = [
          "*"
          "@"
        ];

        passwordFile = config.sec."dynamicdns/vappie.space".path;
      };
    };
  };
}
