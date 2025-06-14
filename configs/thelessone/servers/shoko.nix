{
  self,
  lib,
  config,
  ...
}:

{
  imports = [ self.nixosModules.shoko ];

  services.shoko.enable = true;

  systemd.services.shoko.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "shoko";
    Group = config.services'.lab-config.arr.group;
  };

  users.users.shoko = {
    isSystemUser = true;
    inherit (config.services'.lab-config.arr) group;
    home = config.systemd.services.shoko.environment.SHOKO_HOME;
    homeMode = builtins.toString config.systemd.services.shoko.serviceConfig.StateDirectoryMode;
  };

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
