{
  pkgs,
  inputs,
  config,
  ...
}:

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

    age.keyFile = "${config.hm.xdg.configHome}/sops/age/keys.txt";

    secrets."users/hana/password" = { };
  };

  environment.systemPackages = with pkgs; [ sops ];
}
