{ pkgs, config, ... }:

{
  sops.secrets.vaultwarden-smtp-password.owner = "vaultwarden";
  sops.templates."vaultwarden.env".file = (pkgs.formats.keyValue { }).generate "vaultwarden.env" {
    SMTP_PASSWORD = config.sops.placeholder.vaultwarden-smtp-password;
  };

  services.vaultwarden = {
    config = {
      SMTP_HOST = "smtp.gmail.com";
      SMTP_PORT = 587;
      SMTP_SECURITY = "starttls";

      SMTP_USERNAME = "hanakretzer@gmail.com";
      SMTP_FROM = "hanakretzer+vaultwarden@gmail.com";
      SMTP_FROM_NAME = "${config.config'.caddy.baseDomain} Vaultwarden Server";

      SIGNUPS_ALLOWED = false;
      SIGNUPS_VERIFY = true;
      REQUIRE_DEVICE_EMAIL = true;

      ORG_CREATION_USERS = "hanakretzer@gmail.com";
    };

    environmentFile = config.sops.templates."vaultwarden.env".path;
  };

  config'.vaultwarden.enable = true;
}
