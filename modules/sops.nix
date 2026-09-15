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

  modules.nixos.sops =
    { pkgs, ... }:

    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      environment.systemPackages = [ pkgs.sops ];
      sops.defaultSopsFormat = "yaml";
    };

  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.sops ];
  };

  configurations.home."hana@kanokoyuri" = {
    imports = [ config.modules.home.sops ];
  };

  modules.home.sops =
    { pkgs, config, ... }:

    {
      imports = [ inputs.sops-nix.homeModules.default ];

      home.packages = [ pkgs.sops ];
      sops = {
        defaultSopsFormat = "yaml";
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };
    };
}
