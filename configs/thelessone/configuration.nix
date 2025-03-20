{ pkgs, username, ... }:

{
  nanoflake.localization = {
    timezone = "Europe/Vienna";
    language = "de_AT";
    locale = "de_AT.UTF-8";
  };

  environment.systemPackages = with pkgs; [
    vesktop
    vscodium
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

  system.stateVersion = "24.11";
  hm.home.stateVersion = "24.11";
}
