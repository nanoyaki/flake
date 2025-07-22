{ lib, pkgs, ... }:

{
  boot.kernelModules = [ "i2c-piix4" ];
  hardware.i2c.enable = true;

  services.udev.packages = [ pkgs.openrgb ];
  systemd.services.no-rgb = {
    description = "no-rgb";

    serviceConfig = {
      ExecStart = pkgs.writeShellScript "no-rgb" ''
        NUM_DEVICES=$(${lib.getExe pkgs.openrgb} --noautoconnect --list-devices | grep -E '^[0-9]+: ' | wc -l)

        for i in $(seq 0 $((NUM_DEVICES - 1))); do
          ${lib.getExe pkgs.openrgb} --noautoconnect --device $i --mode static --color 000000
        done
      '';
      Type = "oneshot";
    };

    wantedBy = [ "multi-user.target" ];
  };
}
