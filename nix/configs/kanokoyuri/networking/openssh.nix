{
  flake.nixosModules.kanokoyuri-openssh =
    { config, ... }:

    {
      networking = {
        hostId = "69804090";
        hostName = "kanokoyuri";
        domain = "hanakretzer.de";
        fqdn = "de01.hanakretzer.de";
      };

      services.openssh = {
        enable = true;
        openFirewall = true;

        settings.PasswordAuthentication = false;
      };

      users.users.${config.self.mainUser}.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP3poqMv85Pqb5gwZRZYN2BLW+OAiMT5ZA0tQHUo977W hana@shirayuri"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGTdis9sEaWC/dHRq6a5sTrcBQmQuDQ+OxzJQuhnx/daAAAABHNzaDo= hana@shirayuri"
      ];
    };
}
