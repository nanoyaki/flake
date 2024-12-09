{
  lib,
  pkgs,
  inputs,
  config,
  username,
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

    secrets = {
      "nixos/users/hana".owner = ifUser "hana";
      "nixos/users/thelessone".owner = ifUser "thelessone";

      "deployment/private".owner = username;
      "deployment/public".mode = "0444";
    };
  };

  environment.systemPackages = [ pkgs.sops ];
}
