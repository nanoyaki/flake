{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) concatMapAttrsStringSep escapeShellArg;

  cfg = config.boot.lanzaboote;

  loaderSettingsFormat = pkgs.formats.keyValue {
    mkKeyValue = k: v: if v == null then "" else lib.generators.mkKeyValueDefault { } " " k v;
  };

  loaderConfigFile = loaderSettingsFormat.generate "loader.conf" cfg.settings;

  configurationLimit = if cfg.configurationLimit == null then 0 else cfg.configurationLimit;
in

{
  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];

    kernelPackages = pkgs.linuxKernel.packageAliases.linux_latest;

    loader = {
      efi.efiSysMountPoint = "/boot";

      systemd-boot.enable = lib.mkForce false;

      timeout = 3;

      external.installHook = lib.mkForce (
        pkgs.writeShellScript "bootinstall" (
          let
            inherit (config.boot.loader.efi) efiSysMountPoint;

            edk2ShellEspPath = "efi/edk2-uefi-shell/shell.efi";

            extraEntries."windows_11.conf" = ''
              title Windows 11
              efi /${edk2ShellEspPath}
              options -nointerrupt -nomap -noversion HD1d65535a1:EFI\Microsoft\Boot\Bootmgfw.efi
              sort-key windows
            '';

            extraFiles.${edk2ShellEspPath} = "${pkgs.edk2-uefi-shell}/shell.efi";
          in

          ''
            # Use the system from the kernel's hostPlatform because this should
            # always, even in the cross compilation case, be the right system.
            ${lib.getExe cfg.package} install \
              --system ${config.boot.kernelPackages.stdenv.hostPlatform.system} \
              --systemd ${config.systemd.package} \
              --systemd-boot-loader-config ${loaderConfigFile} \
              --public-key ${cfg.publicKeyFile} \
              --private-key ${cfg.privateKeyFile} \
              --configuration-limit ${toString configurationLimit} \
              ${config.boot.loader.efi.efiSysMountPoint} \
              /nix/var/nix/profiles/system-*-link

            ${concatMapAttrsStringSep "" (n: v: ''
              ${pkgs.coreutils}/bin/install -Dp "${v}" "${efiSysMountPoint}/"${escapeShellArg n}
              ${lib.getExe pkgs.sbctl} sign -s "${efiSysMountPoint}/"${escapeShellArg n}
            '') extraFiles}

            ${concatMapAttrsStringSep "" (n: v: ''
              ${pkgs.coreutils}/bin/install -Dp "${pkgs.writeText n v}" "${efiSysMountPoint}/loader/entries/"${escapeShellArg n}
            '') extraEntries}
          ''
        )
      );
    };

    lanzaboote = {
      enable = true;
      configurationLimit = 100;
      pkiBundle = "/var/lib/sbctl";
    };

    supportedFilesystems = [ "ntfs" ];
  };
}
