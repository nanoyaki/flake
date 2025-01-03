{
  swapDevices = [
    {
      device = "/var/lib/swap/swapfile32";
      size = 32 * 1024;
    }
    # {
    #   device = "/var/lib/swap/swapfile16";
    #   size = 16 * 1024;
    # }
    # {
    #   device = "/var/lib/swap/swapfile8";
    #   size = 8 * 1024;
    # }
  ];

  zramSwap.enable = true;

  systemd.tmpfiles.settings."10-swap"."/var/lib/swap".d = {
    user = "root";
    mode = "0700";
  };
}
