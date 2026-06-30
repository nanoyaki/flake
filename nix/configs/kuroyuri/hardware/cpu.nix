{ withSystem, inputs, ... }:

{
  flake.nixosModules.kuroyuri-cpu =
    { pkgs, ... }:

    {
      imports = with inputs.nixos-hardware.nixosModules; [
        common-cpu-amd
        common-cpu-amd-pstate
        common-cpu-amd-zenpower
      ];

      boot.kernelModules = [
        "kvm-amd"
        "msr"
      ];

      hardware.enableRedistributableFirmware = true;
      hardware.cpu.amd.updateMicrocode = true;

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

  perSystem =
    { pkgs, ... }:

    {
      packages.amdctl = pkgs.amdctl.overrideAttrs {
        patches = [ ./max-vid.patch ];
      };
    };

  flake.overlays.amdctl =
    _: prev:
    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }: {
        inherit (config.packages) amdctl;
      }
    );
}
