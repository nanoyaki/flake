{
  self,
  pkgs,
  username,
  ...
}:

{
  nanoflake.localization = {
    timezone = "Europe/Vienna";
    language = "de_AT";
    locale = "de_AT.UTF-8";
  };

  environment.systemPackages = with pkgs; [
    vesktop
    vscodium
    tmux
    prismlauncher
  ];

  security.sudo.extraRules = [
    {
      users = [ username ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  services.iperf3 = {
    enable = true;
    openFirewall = true;
  };

  # for deployment
  environment.etc."systems/thelessnas".source =
    self.nixosConfigurations.thelessnas.config.system.build.toplevel;

  system.stateVersion = "24.11";
  hm.home.stateVersion = "24.11";
}
