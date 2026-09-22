{ config, ... }:

{
  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.focusrite-scarlett ];
  };

  modules.nixos.focusrite-scarlett = {
    boot.extraModprobeConfig = ''
      options snd_usb_audio vid=0x1235 pid=0x8211 device_setup=1
    '';
  };

  modules.home.focusrite-scarlett =
    { pkgs, ... }:

    {
      home.packages = [ pkgs.alsa-scarlett-gui ];
    };
}
