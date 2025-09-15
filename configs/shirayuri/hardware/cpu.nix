{
  inputs,
  ...
}:

let
  inherit (inputs) vermeer-undervolt;
in

{
  imports = [
    vermeer-undervolt.nixosModules.vermeer-undervolt
  ];

  boot.kernelModules = [
    "kvm-amd"
    "ryzen_smu"
  ];

  hardware.cpu.amd.updateMicrocode = true;
  services.power-profiles-daemon.enable = true;

  services.vermeer-undervolt = {
    enable = true;
    cores = 8;
    milivolts = 30;
  };
}
