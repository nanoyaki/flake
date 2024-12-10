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
  inherit (lib.modules) mkAliasOptionModule;
  inherit (inputs) sops-nix;

  # String -> String
  ifUser = user: mkIf (builtins.elem user (builtins.attrNames config.users.users)) user;
in

{
  imports = [
    sops-nix.nixosModules.sops
    (mkAliasOptionModule
      [ "sec" ]
      [
        "sops"
        "secrets"
      ]
    )
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "${config.hm.xdg.configHome}/sops/age/keys.txt";
  };

  sec = {
    "nixos/users/hana".owner = ifUser "hana";
    "nixos/users/thelessone".owner = ifUser "thelessone";

    "deployment/private".owner = username;
  };

  environment.systemPackages = [ pkgs.sops ];
}
