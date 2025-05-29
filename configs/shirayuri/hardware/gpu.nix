{ pkgs, ... }:

{
  boot.kernelModules = [ "amdgpu" ];

  hardware = {
    amdgpu = {
      initrd.enable = true;
      amdvlk.enable = false;
      overdrive = {
        enable = true;
        ppfeaturemask = "0xffffffff";
      };
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
