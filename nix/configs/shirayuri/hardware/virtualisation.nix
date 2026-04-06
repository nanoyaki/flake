{
  flake.nixosModules.shirayuri-virtualisation =
    { pkgs, ... }:

    {
      boot.extraModprobeConfig = ''
        options kvm_amd nested=1
      '';
      systemd.tmpfiles.settings.qemu."/var/lib/qemu/firmware"."L+".argument =
        "${pkgs.qemu}/share/qemu/firmware";
      services.udev.extraRules = ''
        SUBSYSTEM=="usb", ATTR{idVendor}=="1038", ATTR{idProduct}=="12ae", MODE="0666"
      '';

      programs.virt-manager.enable = true;

      environment.systemPackages = [
        pkgs.quickemu
        pkgs.OVMFFull
      ];

      users.users.hana.extraGroups = [ "libvirtd" ];
      virtualisation.libvirtd.enable = true;
      virtualisation.libvirtd.qemu = {
        runAsRoot = false;
        swtpm.enable = true;
      };
    };
}
