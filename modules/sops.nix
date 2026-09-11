{ inputs, config, ... }:

{
  flake-file.inputs.sops-nix.url = "github:Mic92/sops-nix";

  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.sops ];

    sops.age.keyFile = "/home/hana/.config/sops/age/keys.txt";
  };

  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.sops ];

    sops.age.keyFile = "/home/hana/.config/sops/age/keys.txt";
  };

  modules.nixos.sops = {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops.defaultSopsFormat = "yaml";
  };

  configurations.home."hana@kanokoyuri" = {
    imports = [ config.modules.home.sops ];
  };

  modules.home.sops =
    { config, ... }:

    {
      imports = [ inputs.sops-nix.homeModules.default ];

      sops = {
        defaultSopsFormat = "yaml";
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };
    };
}
