{
  flake.nixosModules.shirayuri-boot =
    { pkgs, ... }:

    {
      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
      boot.binfmt.addEmulatedSystemsToNixSandbox = true;

      boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
      boot.loader = {
        efi.efiSysMountPoint = "/boot";
        systemd-boot.enable = true;
        timeout = 3;
      };
    };
}
