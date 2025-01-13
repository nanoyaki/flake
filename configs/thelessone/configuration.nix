{ pkgs, username, ... }:

{
  sec."deployment/private" = { };

  programs.firefox.enable = true;

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
