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
    defaultSopsFile = ./. + "../../${config.networking.hostName}/secrets.yaml";
    defaultSopsFormat = "yaml";

    age.keyFile = "${config.hm.xdg.configHome}/sops/age/keys.txt";
  };

  environment.systemPackages = [ pkgs.sops ];
}
