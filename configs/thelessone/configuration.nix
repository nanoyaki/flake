{
  self,
  pkgs,
  inputs',
  username,
  ...
}:

{
  nanoflake.localization = {
    timezone = "Europe/Vienna";
    language = "de_AT";
    locale = "de_AT.UTF-8";
  };

  nix.settings.trusted-substituters = [ "https://prismlauncher.cachix.org" ];
  nix.settings.trusted-public-keys = [
    "prismlauncher.cachix.org-1:9/n/FGyABA2jLUVfY+DEp4hKds/rwO+SCOtbOkDzd+c="
  ];

  environment.systemPackages =
    (with pkgs; [
      vesktop
      vscodium
      tmux
    ])
    ++ [
      inputs'.prismlauncher.packages.prismlauncher
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

  # for deployment
  environment.etc."systems/thelessnas".source =
    self.nixosConfigurations.thelessnas.config.system.build.toplevel;

  system.stateVersion = "24.11";
  hm.home.stateVersion = "24.11";
}
