{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.amdgpu;
  inherit (lib) mkIf mkOption types;

  amdgpu-kernel-module = pkgs.callPackage ../pkgs/amdgpu/package.nix {
    kernel = config.boot.kernelPackages.kernel;
  };
in

{
  options.modules.amdgpu.patches = mkOption {
    type = with types; listOf path;
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
