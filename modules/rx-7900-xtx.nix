{ config, ... }:

{
  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.rx-7900-xtx ];
  };

  modules.nixos.rx-7900-xtx =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    let
      inherit (lib) mkEnableOption mkIf;
    in

    {
      options.hardware.rx-7900-xtx.enable = mkEnableOption "RX 7900 XTX support" // {
        default = true;
      };

      config = mkIf config.hardware.rx-7900-xtx.enable {
        boot.kernelModules = [ "amdgpu" ];

        services.xserver.videoDrivers = [ "modesetting" ];

        hardware.amdgpu = {
          initrd.enable = true;
          opencl.enable = true;
          zluda.enable = true;
          overdrive.enable = true;
          overdrive.ppfeaturemask = "0xffffffff";
        };

        hardware.graphics.enable = true;
        hardware.graphics.enable32Bit = true;

        environment.variables.VDPAU_DRIVER = "radeonsi";
        environment.variables.AMD_VULKAN_ICD = "RADV";

        systemd.tmpfiles.settings.rocm."/opt/rocm"."L+".argument =
          (pkgs.symlinkJoin {
            name = "rocm-combined";
            paths = with pkgs.rocmPackages; [
              rocblas
              hipblas
              clr
            ];
          }).outPath;
      };
    };

  modules.nixos.nix =
    {
      lib,
      options,
      config,
      ...
    }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf ((options ? hardware.rx-7900-xtx.enable) && config.hardware.rx-7900-xtx.enable) {
        nixpkgs.config.rocmSupport = true;
      };
    };
}
