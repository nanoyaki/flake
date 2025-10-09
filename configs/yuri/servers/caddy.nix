{
  config'.caddy = {
    enable = true;

    baseDomain = "nanoyaki.space";
    useHttps = true;
    openFirewall = true;
  };

  services.caddy = {
    dataDir = "/mnt/nvme-raid-1/var/lib/caddy";
    logDir = "/mnt/nvme-raid-1/var/log/caddy";
  };

  services.caddy.virtualHosts = {
    "nanoyaki.space".extraConfig = "redir https://bsky.app/profile/nanoyaki.space permanent";
    "www.nanoyaki.space".extraConfig = "redir https://bsky.app/profile/nanoyaki.space permanent";
    "twitter.nanoyaki.space".extraConfig = "redir https://x.com/nanoyaki permanent";
    "hubby.nanoyaki.space".extraConfig = "redir https://bsky.app/profile/vappie.space permanent";
  };
}
