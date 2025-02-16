{ inputs, ... }:

let
  inherit (inputs) vermeer-undervolt;
in

{
  imports = [
    vermeer-undervolt.nixosModules.vermeer-undervolt
  ];

  hardware.cpu.amd.updateMicrocode = true;

  services.vermeer-undervolt = {
    enable = true;
    cores = 8;
    milivolts = 30;
  };
}
