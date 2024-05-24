{
  sysconfig,
  pkgs,
  username,
  inputs,
  ...
}: let
  inherit (inputs) home-manager;
in {
  imports = [
    home-manager.nixosModules.home-manager
  ];

  config = {
    home.file.".config/mongodb/" = {
      source = ./configs;
      recursive = true;
    };

    environment.systemPackages = [pkgs.mongodb];
  };
}
