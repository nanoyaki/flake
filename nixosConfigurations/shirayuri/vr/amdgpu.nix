{
  config,
  lib,
  packages,
  ...
}:

let
  cfg = config.hardware.amdgpu;
  inherit (lib) mkIf mkOption types;

  amdgpu-kernel-module = packages.amdgpu.override {
    inherit (config.boot.kernelPackages) kernel;
  };
in

{
  options.hardware.amdgpu.patches = mkOption {
    type = with types; listOf path;
    default = [ ];
  };

  config = mkIf (cfg.patches != [ ]) {
    boot.extraModulePackages = [
      (amdgpu-kernel-module.overrideAttrs (prev: {
        patches = (prev.patches or [ ]) ++ cfg.patches;
      }))
    ];
  };
}

# https://github.com/Scrumplex/flake/blob/5d1bbf1d774862dba63e54ff6d1662a859e3ec87/nixosConfigurations/common/amdgpu/default.nix
