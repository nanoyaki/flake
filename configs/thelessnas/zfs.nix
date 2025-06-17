{
  config,
  lib,
  pkgs,
  ...
}:

let
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
  ) pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in

{
  boot = {
    kernelPackages = latestKernelPackage;
    supportedFilesystems.zfs = true;
    zfs.forceImportRoot = false;
    zfs.extraPools = [ "moon" ];
  };

  networking.hostId = "23d2908a";

  services.zfs.autoScrub.enable = true;

  systemd.services.zfs-mount.enable = false;
}
