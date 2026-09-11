{ config, ... }:

{
  configurations.nixos.himawari =
    { pkgs, ... }:

    {
      imports = [ config.modules.nixos.plasma ];

      # Luks
      systemd.services.plasmalogin.serviceConfig.KeyringMode = "inherit";
      security.pam.services.plasmalogin-autologin.rules.auth = {
        systemd_loadkey = {
          order = 0;
          control = "optional";
          modulePath = "${pkgs.systemd}/lib/security/pam_systemd_loadkey.so";
        };

        plasmalogin = {
          order = 1;
          control = "include";
          modulePath = "plasmalogin";
        };
      };
    };

  modules.nixos.plasma = {
    services.desktopManager.plasma6.enable = true;
    services.displayManager.plasma-login-manager.enable = true;
  };
}
