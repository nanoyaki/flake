{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (inputs) sops-nix;

  # String -> String
  ifUser = user: mkIf (builtins.elem user (builtins.attrNames config.users.users)) user;
in

{
  imports = [
    sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "${config.hm.xdg.configHome}/sops/age/keys.txt";

    secrets."nixos/users/hana".owner = ifUser "hana";
    secrets."nixos/users/thelessone".owner = ifUser "thelessone";
  };

  environment.systemPackages = [ pkgs.sops ];
}
