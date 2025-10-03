{
  self,
  pkgs,
  config,
  ...
}:

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

  # for deployment
  environment.etc."systems/thelessnas".source =
    self.nixosConfigurations.thelessnas.config.system.build.toplevel;

  systemd.tmpfiles.settings."10-restic-backups"."/mnt/raid/backups".d = {
    mode = "0700";
    user = "root";
    group = "wheel";
  };
}
