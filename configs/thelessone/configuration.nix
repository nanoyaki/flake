{
  self,
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (config.hm.lib.cosmic) mkRON;
  Some = mkRON "optional";
  None = mkRON "optional" null;
in

{
  config' = {
    librewolf.enable = true;
    theming.enable = true;
    steam.enable = true;
  };

  environment.systemPackages = with pkgs; [
    vesktop
    vscodium
    tmux
    prismlauncher
  ];

  security.sudo.extraRules = [
    {
      users = [ config.nanoSystem.mainUserName ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  hms = lib.singleton {
    wayland.desktopManager.cosmic.idle = {
      screen_off_time = Some 90000;
      suspend_on_ac_time = None;
      suspend_on_battery_time = None;
    };
  };

  # for deployment
  environment.etc."systems/thelessnas".source =
    self.nixosConfigurations.thelessnas.config.system.build.toplevel;

  systemd.tmpfiles.settings."10-restic-backups"."/mnt/raid/backups".d = {
    mode = "0700";
    user = "root";
    group = "wheel";
  };
}
