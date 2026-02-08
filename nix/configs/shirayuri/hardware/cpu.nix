{ inputs, ... }:

{
  flake.nixosModules.shirayuri-cpu = {
    imports = [
      inputs.vermeer-undervolt.nixosModules.vermeer-undervolt
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
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
  };
}
