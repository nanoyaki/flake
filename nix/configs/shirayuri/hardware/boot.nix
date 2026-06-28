{
  flake.nixosModules.shirayuri-boot =
    { pkgs, ... }:

    {
      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
      boot.binfmt.addEmulatedSystemsToNixSandbox = true;

      # temporarily switch to xanmod
      boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
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
