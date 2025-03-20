{ username, ... }:

{
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings.PasswordAuthentication = false;
  };

  services.fail2ban = {
    enable = true;
    maxretry = 2;
    bantime = "1h";
  };

  users.users.${username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP3poqMv85Pqb5gwZRZYN2BLW+OAiMT5ZA0tQHUo977W hana@shirayuri"
  ];
}
