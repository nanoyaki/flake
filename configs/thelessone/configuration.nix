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

  deployment = {
    targetUser = "root";
    targetHost = "theless.one";
    privateKeyName = "deploymentThelessone";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMc3xjLJxASdTuLIrsvok5Wpm5N8TO1CI9vHt2z3oPPC";
    knownHosts = [ "theless.one" ];
    extraFlags = [ "--print-build-logs" ];
  };

  system.stateVersion = "24.11";
  hm.home.stateVersion = "24.11";
}
