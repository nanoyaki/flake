{
  config'.homepage = {
    enable = true;
    subdomain = "";

    categories = {
      Media.before = "Services";
      Services.before = "Code";
      "Media services".layout = {
        style = "row";
        columns = 4;
      };
    };

    glances.layout.columns = 3;
    glances.widgets = [
      { "CPU usage".metric = "cpu"; }
      { "Memory usage".metric = "memory"; }
      { "Network usage".metric = "network:enp6s0"; }
      { "VPN Network usage".metric = "network:tailscale0"; }
      { "Storage usage NVMe".metric = "fs:/"; }
      { "Disk I/O NVMe".metric = "disk:nvme0n1"; }
    ];
  };

  config'.caddy.reverseProxies."https://theless.one".useMtls = true;

  config'.homepage-images.enable = true;
}
