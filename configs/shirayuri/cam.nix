{
  programs.droidcam.enable = true;
  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1
  '';
}
