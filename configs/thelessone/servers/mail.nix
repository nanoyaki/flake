{ inputs, config, ... }:

{
  imports = [ inputs.snm.nixosModules.mailserver ];

  sops.secrets = {
    "mailserver/nanoyaki" = { };
  };

  mailserver = {
    enable = true;
    stateVersion = 3;
    fqdn = "mail.theless.one";
    domains = [ "theless.one" ];

    loginAccounts = {
      "nanoyaki@theless.one" = {
        hashedPasswordFile = config.sops.secrets."mailserver/nanoyaki".path;
        aliases = [
          "postmaster@theless.one"
          "hana@theless.one"
        ];
      };
      "thelessone@theless.one" = {
        hashedPasswordFile = config.sops.secrets."mailserver/thelessone".path;
        aliases = [ "thomas@theless.one" ];
      };
    };

    certificateScheme = "acme";
    acmeCertificateName = "theless.one";

    dkimSigning = true;
    dkimKeyType = "rsa";
    dkimKeyBits = 4096;
    dkimSelector = "mail";

    dmarcReporting.enable = true;

    fullTextSearch.substringSearch = true;
    fullTextSearch.languages = [
      "en"
      "de"
    ];
  };
}
