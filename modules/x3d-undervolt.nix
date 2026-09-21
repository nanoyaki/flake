{ inputs, config, ... }:

{
  flake-file.inputs.vermeer-undervolt.url = "github:nanoyaki/5800x3d-undervolt";

  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.x3d-undervolt ];
  };

  modules.nixos.x3d-undervolt = {
    imports = [ inputs.vermeer-undervolt.nixosModules.vermeer-undervolt ];

    services.vermeer-undervolt = {
      enable = true;
      cores = 8;
      milivolts = 30;
    };
  };
}
