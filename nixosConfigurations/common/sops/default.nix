{ pkgs, inputs, ... }:

let
  inherit (inputs) sops-nix;
in

{
  imports = [
    sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/home/hana/.config/sops/age/keys.txt";

    secrets.test_key = { };
  };

  environment.systemPackages = with pkgs; [ sops ];
}
