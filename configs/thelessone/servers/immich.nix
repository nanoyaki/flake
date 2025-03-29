{
  nixpkgs.overlays = [
    (_: prev: {
      immich-machine-learning = prev.immich-machine-learning.overrideAttrs {
        disabledTests = [
          # Fails when onnxruntime has cudaSupport=true https://github.com/NixOS/nixpkgs/issues/352113
          # when running a version that fails this test I see no issues using immich with cuda
          # https://github.com/immich-app/immich/blob/2c88ce8559160a020d72aec753f8c4dc0128ef1c/machine-learning/app/test_main.py#L241
          "test_sets_default_sess_options"
        ];
      };
      python3 = prev.python3.override {
        packageOverrides = _: pyPrev: {
          albumentations = pyPrev.albumentations.overridePythonAttrs {
            disabledTestPaths = [ "tests/test_transforms.py" ];
          };
        };
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
