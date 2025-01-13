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

  cfg = {
    defaultSopsFile = ./. + "../../${config.networking.hostName}/secrets.yaml";
    defaultSopsFormat = "yaml";

    age.keyFile = "${config.hm.xdg.configHome}/sops/age/keys.txt";
  };
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

  home-manager.sharedModules = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = cfg;
  hm.sops = cfg;
  hm.imports = [
    (mkAliasOptionModule
      [ "sec" ]
      [
        "sops"
        "secrets"
      ]
    )
  ];

  environment.systemPackages = [ pkgs.sops ];
}
