{ inputs, config, ... }:

{
  flake-file.inputs.bc250.url = "github:TesseractCat/bc250-nixos";

  configurations.nixos.meow = {
    imports = [ config.modules.nixos.bc250 ];
  };

  modules.nixos.bc250 = {
    imports = [ inputs.bc250.nixosModules.bc250 ];

    services.cyan-skillfish-governor-smu.settings.gpu-usage.fix-freq = true;

    hardware.bc250.enable = true;
    hardware.bc250.features = {
      zswap.enable = false;
      coreUnlock.enable = true;
      cuLiveManager.enable = true;
    };
  };
}
