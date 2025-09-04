{
  swapDevices = [
    {
      device = "/var/swap";
      size = 8 * 1024;
    }
  ];

  zramSwap.enable = true;
}
