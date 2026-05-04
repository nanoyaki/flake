{
  flake.nixosModules.shirayuri-boot =
    { pkgs, ... }:

    {
      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
      boot.binfmt.addEmulatedSystemsToNixSandbox = true;

      boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
      boot.loader = {
        efi.efiSysMountPoint = "/boot";

        timeout = 3;
        limine = {
          enable = true;
          secureBoot.enable = true;

          extraEntries = ''
            /Windows
              protocol: efi
              path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
          '';
        };
      };
    };
}
