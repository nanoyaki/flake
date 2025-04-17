{ pkgs, config, ... }:

{
  boot.kernelModules = [ "amdgpu" ];
  boot.extraModulePackages = [
    (pkgs.amdgpu-i2c.override { inherit (config.boot.kernelPackages) kernel; })
  ];

  hardware = {
    amdgpu = {
      initrd.enable = true;
      amdvlk.enable = false;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  environment.variables.VDPAU_DRIVER = "radeonsi";
  services.xserver.videoDrivers = [ "amdgpu" ];

  systemd.tmpfiles.rules =
    let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs.rocmPackages; [
          rocblas
          hipblas
          clr
        ];
      };
    in
    [
      "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
    ];
}
