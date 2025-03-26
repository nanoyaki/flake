{
  nixpkgs.overlays = [
    (final: prev: {
      python313Packages.onnxruntime = prev.python313Packages.onnxruntime.override {
        cudaSupport = false;
        ncclSupport = false;
      };
    })
  ];

  services.immich = {
    enable = true;
    port = 2283;
    accelerationDevices = [ "/dev/dri/renderD128" ];
  };

  users.users.immich.extraGroups = [
    "video"
    "render"
  ];
}
