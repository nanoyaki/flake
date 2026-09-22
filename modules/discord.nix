{ config, ... }:

{
  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.discord ];
  };

  configurations.home."hana@shirayuri" = {
    imports = [ config.modules.home.discord ];
  };

  modules.home.discord = _: {
    programs.equibop = {
      enable = true;
      equicord.settings.FakeNitro.enabled = true;
      settings = {
        # NixOS after all
        checkUpdates = false;

        appBadge = false;
        arRPC = true;
        customTitleBar = false;
        disableMinSize = true;
        splashTheming = true;
        staticTitle = true;
        hardwareAcceleration = true;
        discordBranch = "stable";
      };
    };
  };

  modules.home.niri =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.equibop.enable {
        # Avoid the tray, use workspaces instead
        programs.equibop.settings.tray = false;
        programs.equibop.settings.minimizeToTray = false;
      };
    };
}
