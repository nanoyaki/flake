{ inputs, config, ... }:

{
  imports = [ inputs.snm.nixosModules.mailserver ];

  sops.secrets = {
    "mailserver/postmaster" = { };
    "mailserver/nanoyaki" = { };
    "mailserver/thelessone" = { };
    "mailserver/vaultwarden" = { };
    "mailserver/calendar" = { };
    "mailserver/git" = { };
  };

  mailserver = {
    enable = true;
    stateVersion = 3;
    fqdn = "mail.theless.one";
    domains = [
      "theless.one"
      "nanoyaki.space"
    ];

    loginAccounts = {
      "postmaster@theless.one" = {
        hashedPasswordFile = config.sops.secrets."mailserver/postmaster".path;
        aliases = [ "postmaster@nanoyaki.space" ];
      };

      "nanoyaki@theless.one" = {
        hashedPasswordFile = config.sops.secrets."mailserver/nanoyaki".path;
        aliases = [
          "hana@theless.one"
          "hanakretzer@nanoyaki.space"
          "hana@nanoyaki.space"
          "nanoyaki@nanoyaki.space"
          "nano@nanoyaki.space"
          "contact@nanoyaki.space"
        ];
        aliasesRegexp = [
          ''/^nano(\.|\+).*@nanoyaki\.space$/''
        ];
      };

      "thelessone@theless.one" = {
        hashedPasswordFile = config.sops.secrets."mailserver/thelessone".path;
        aliases = [
          "thomas@theless.one"
          "contact@theless.one"
        ];
      };

      "vaultwarden@theless.one" = {
        sendOnly = true;
        hashedPasswordFile = config.sops.secrets."mailserver/vaultwarden".path;
      };

      "calendar@theless.one" = {
        sendOnly = true;
        hashedPasswordFile = config.sops.secrets."mailserver/calendar".path;
      };

      "git@theless.one" = {
        sendOnly = true;
        hashedPasswordFile = config.sops.secrets."mailserver/git".path;
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

  sops.secrets = {
    "restic/mail-local" = { };
    "restic/mail-remote" = { };
  };

  sops.templates."restic-mail-repo.txt".content = ''
    rest:http://restic:${config.sops.placeholder."restic/100-64-64-3"}@100.64.64.3:8000/mail-thelessone
  '';

  config'.restic.backups = rec {
    mail-local = {
      repository = "/mnt/raid/backups/mail";
      passwordFile = config.sops.secrets."restic/mail-local".path;

      basePath = "/var";
      paths = [
        "vmail"
        "sieve"
        "lib/redis-rspamd"
        "dkim"
      ];

      timerConfig.OnCalendar = "daily";
    };

    mail-remote = mail-local // {
      repository = null;
      repositoryFile = config.sops.templates."restic-mail-repo.txt".path;
      passwordFile = config.sops.secrets."restic/mail-remote".path;
    };
  };
}
