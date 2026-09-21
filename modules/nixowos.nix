{ inputs, config, ... }:

{
  flake-file.inputs.nixowos.url = "github:yunfachi/NixOwOS";

  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.nixowos ];
  };

  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.nixowos ];
  };

  modules.nixos.nixowos = {
    imports = [ inputs.nixowos.nixosModules.default ];

    nixowos.enable = true;
  };

  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.nixowos ];
  };

  configurations.home."hana@shirayuri" = {
    imports = [ config.modules.home.nixowos ];
  };

  modules.home.nixowos = {
    imports = [ inputs.nixowos.homeModules.default ];

    nixowos.enable = true;
  };
}
