{
  pkgs,
  inputs,
  username,
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

    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";

    secrets."users/hana/password" = { };
    secrets."spotify/password".owner = username;
  };

  environment.systemPackages = with pkgs; [ sops ];
}
