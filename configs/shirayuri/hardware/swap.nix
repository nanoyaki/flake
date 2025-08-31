{
  swapDevices = [
    {
      device = "/swap";
      size = 32 * 1024;
    }
  ];

  boot.resumeDevice = "/dev/nvme1n1";
  boot.kernelParams = [ "resume_offset=157558016" ];
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=1h
    SuspendState=mem
  '';

  zramSwap.enable = true;
}
