{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:

let
  inherit (lib.modules) mkAliasOptionModule;
  inherit (inputs) sops-nix;
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

  sec."deployment/private".owner = config.hm.home.username;

  environment.systemPackages = [ pkgs.sops ];
}
