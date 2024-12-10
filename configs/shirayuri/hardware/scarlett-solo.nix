{ pkgs, ... }:
{
  boot.extraModprobeConfig = ''
    options snd_usb_audio vid=0x1235 pid=0x8211 device_setup=1
  '';

  environment.systemPackages = with pkgs; [ alsa-scarlett-gui ];
}
