{ config, ... }:

{
  sec."nix-serve" = { };

  services.nix-serve = {
    enable = true;
    secretKeyFile = config.sec."nix-serve".path;
  };
}
