{ lib, pkgs, ... }:

{
  boot.kernelModules = [
    "kvm-amd"
    "msr"
  ];

  hardware.cpu.amd.updateMicrocode = true;

  services.power-profiles-daemon.enable = true;

  systemd.services.amdctl-undervolt =
    let
      amdctl = lib.getExe (
        pkgs.amdctl.overrideAttrs {
          patches = [
            ./max-vid.patch
          ];
        }
      );
    in
    {
      enable = true;
      description = "Undervolt by ~30 milivolts";

      wantedBy = [ "multi-user.target" ];

      script = ''
        ${amdctl} -m
        ${amdctl} -p0 -v196
        ${amdctl} -p1 -v176
        ${amdctl} -p2 -v156
      '';

      serviceConfig = {
        User = "root";
        Group = "wheel";
      };
    };
}
