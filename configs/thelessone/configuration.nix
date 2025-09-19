{
  self,
  pkgs,
  config,
  ...
}:

{
  config' = {
    localization = {
      timezone = "Europe/Vienna";
      language = "de_AT";
      locale = "de_AT.UTF-8";
    };

    librewolf.enable = true;
    theming.enable = true;
    steam.enable = true;
    rgb.disable = true;
  };

  sops.secrets = {
    "uptime-kuma/user" = { };
    "uptime-kuma/password" = { };
  };

  sops.templates."rbm.env".file = (pkgs.formats.keyValue { }).generate "rbm.env" {
    UPTIME_KUMA_URL = "https://status.nanoyaki.space/";
    UPTIME_KUMA_USER = config.sops.placeholder."uptime-kuma/user";
    UPTIME_KUMA_PASSWORD = "'${config.sops.placeholder."uptime-kuma/password"}'";
    MAINTENANCE_AFFECTED_STATUS_PAGES = "thelessone";
  };

  environment.systemPackages = with pkgs; [
    vesktop
    vscodium
    tmux
    prismlauncher
  ];

  security.sudo.extraRules = [
    {
      users = [ config.config'.mainUserName ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # for deployment
  environment.etc."systems/thelessnas".source =
    self.nixosConfigurations.thelessnas.config.system.build.toplevel;

  systemd.tmpfiles.settings."10-restic-backups"."/mnt/raid/backups".d = {
    mode = "0700";
    user = "root";
    group = "wheel";
  };
}
