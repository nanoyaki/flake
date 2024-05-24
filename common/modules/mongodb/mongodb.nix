{
  sysconfig,
  pkgs,
  username,
  inputs,
  ...
}: let
  inherit (inputs.home-manager.nixosModules.home-manager.home-manager.users.${username}) home;
in {
  home.file.".config/mongodb/" = {
    source = ./configs;
    recursive = true;
  };

  sysconfig.environment.systemPackages = [pkgs.mongodb];
}
