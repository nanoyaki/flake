{ inputs, withSystem, ... }:

{
  flake.nixosModules.kuroyuri-cpu =
    { pkgs, ... }:

    {
      imports = with inputs.nixos-hardware.nixosModules; [
        common-cpu-amd
        common-cpu-amd-pstate
        common-cpu-amd-zenpower
      ];

      hardware.cpu.amd.updateMicrocode = true;
      hardware.enableRedistributableFirmware = true;

      boot.kernelModules = [
        "kvm-amd"
        "msr"
      ];

      environment.systemPackages = [ pkgs.amdctl ];

      systemd.services.amdctl-undervolt = {
        enable = true;
        description = "Undervolt by ~30 milivolts";
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.amdctl ];

        script = ''
          amdctl -m
          amdctl -p0 -v196
          amdctl -p1 -v176
          amdctl -p2 -v156
        '';
      };
    };

  flake.overlays.amdctl =
    _: prev:
    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }: {
        inherit (config.packages) amdctl;
      }
    );

  perSystem =
    { pkgs, ... }:

    {
      packages.amdctl = pkgs.amdctl.overrideAttrs {
        patches = [ ./max-vid.patch ];
      };
    };
}
