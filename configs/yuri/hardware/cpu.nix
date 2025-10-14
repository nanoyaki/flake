{ pkgs, ... }:

{
  boot.kernelModules = [ "msr" ];

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  services.power-profiles-daemon.enable = true;

  environment.systemPackages = [ pkgs.amdctl ];
  systemd.services.amdctl-undervolt = {
    description = "Undervolt by ~30 milivolts";

    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.amdctl ];

    script = ''
      amdctl -m
      amdctl -p0 -v29
      amdctl -p1 -v97
      amdctl -p2 -v113
    '';

    serviceConfig = {
      Type = "oneshot";
      Restart = "no";

      User = "root";
      Group = "root";
    };
  };
}
