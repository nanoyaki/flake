{ inputs, ... }:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/home/hana/.config/sops/age/keys.txt";

    secrets.test_key = { };
  };
}
