{ pkgs, ... }:

{
  config' = {
    localization.language = [
      "en_GB"
      "de_DE"
    ];
    nix.flakeDir = "/home/admin/flake";
  };

  environment.systemPackages = [ pkgs.libraspberrypi ];
}
