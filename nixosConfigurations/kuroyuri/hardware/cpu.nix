{ lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (_: prev: {
      amdctl = prev.amdctl.overrideAttrs {
        patches = [ ./max-vid.patch ];
      };
    })
  ];

  boot.kernelModules = [
    "kvm-amd"
    "msr"
  ];

  hardware.cpu.amd.updateMicrocode = true;

  services.power-profiles-daemon.enable = true;

  environment.systemPackages = [ pkgs.amdctl ];
  systemd.services.amdctl-undervolt =
    let
      amdctl = lib.getExe pkgs.amdctl;
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
