{ inputs, ... }:

{
  imports = [ inputs.vermeer-undervolt.nixosModules.vermeer-undervolt ];

  hardware.cpu.amd.ryzen-smu.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  services.power-profiles-daemon.enable = true;

  services.vermeer-undervolt = {
    enable = true;
    cores = 8;
    milivolts = 30;
  };
}
