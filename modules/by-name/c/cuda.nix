{
  lib',
  lib,
  config,
  ...
}:

{
  options.config'.cuda.enable = lib'.options.mkFalseOption;

  config = lib.mkIf config.config'.cuda.enable {
    nix.settings = {
      substituters = [
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };

    nixpkgs.config.cudaSupport = true;
  };
}
