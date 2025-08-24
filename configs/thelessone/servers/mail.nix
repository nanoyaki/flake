{ inputs, config, ... }:

{
  imports = [ inputs.snm.nixosModules.mailserver ];

  sops.secrets = {
    "mailserver/nanoyaki" = { };
  };

  mailserver = {
    enable = true;
    stateVersion = 3;
    fqdn = "theless.one";
    domains = [ config.mailserver.fqdn ];

    loginAccounts."nanoyaki@theless.one" = {
      hashedPasswordFile = config.sops.secrets."mailserver/nanoyaki".path;
      aliases = [ "postmaster@theless.one" ];
    };

    certificateScheme = "acme";

    dkimSigning = true;
    dkimKeyType = "ed25519";
    dkimSelector = "mail";

    dmarcReporting.enable = true;

    fullTextSearch.substringSearch = true;
    fullTextSearch.languages = [
      "en"
      "de"
    ];
  };
}
