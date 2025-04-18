{ lib, pkgs, ... }:

let
  openrgb = pkgs.openrgb-latest;
in

{
  services.udev.packages = [ openrgb ];
  boot.kernelModules = [
    "i2c-dev"
    "i2c-piix4"
  ];
  hardware.i2c.enable = true;

  systemd.services.no-rgb = {
    description = "no-rgb";

    serviceConfig = {
      ExecStart = pkgs.writeShellScript "no-rgb" ''
        NUM_DEVICES=$(${lib.getExe openrgb} --noautoconnect --list-devices | grep -E '^[0-9]+: ' | wc -l)

        for i in $(seq 0 $(($NUM_DEVICES - 1))); do
          ${lib.getExe openrgb} --noautoconnect --device $i --mode static --color 000000
        done
      '';
      Type = "oneshot";
    };

    wantedBy = [ "multi-user.target" ];
  };
}
