{
  services.caddy.virtualHosts = {
    "nanoyaki.space".extraConfig = "redir https://bsky.app/profile/nanoyaki.space permanent";
    "www.nanoyaki.space".extraConfig = "redir https://bsky.app/profile/nanoyaki.space permanent";
    "twitter.nanoyaki.space".extraConfig = "redir https://x.com/nanoyaki permanent";
    "hubby.nanoyaki.space".extraConfig = "redir https://bsky.app/profile/vappie.space permanent";
  };
}
