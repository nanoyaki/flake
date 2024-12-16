{
  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024;
    }
  ];

  zramSwap.enable = true;
}
