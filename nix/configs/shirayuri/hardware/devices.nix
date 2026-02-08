{ inputs, ... }:

{
  flake.nixosModules.shirayuri-devices =
    { pkgs, ... }:

    {
      imports = [ inputs.nixos-hardware.nixosModules.common-pc-ssd ];

      hardware.enableRedistributableFirmware = true;
      hardware.steam-hardware.enable = true;
      hardware.bluetooth.enable = true;
      hardware.logitech.wireless = {
        enable = true;
        enableGraphical = true;
      };

      environment.systemPackages = [ pkgs.alsa-scarlett-gui ];
      boot.extraModprobeConfig = ''
        options snd_usb_audio vid=0x1235 pid=0x8211 device_setup=1
      '';
    };
}
