{ self, ... }:

{
  imports = [ self.nixosModules.shoko ];

  services.shoko.enable = true;

  services'.caddy.reverseProxies."shoko.vpn.theless.one" = {
    port = 8111;
    vpnOnly = true;
  };

  services'.homepage.categories."Media services".services.Shoko = rec {
    description = "Anime manager";
    icon = "shoko.svg";
    href = "https://shoko.vpn.theless.one";
    siteMonitor = href;
  };
}
