{ config, ... }:
{
  sops.secrets = {
    "theless.one-certs/client.crt" = {
      mode = "0444";
      owner = "root";
      group = "thelessone";
      path = "/etc/ssl/certs/client-cert.pem";
    };

    "theless.one-certs/client.key" = {
      mode = "0440";
      owner = "root";
      group = "thelessone";
      path = "/etc/ssl/private/client-key.pem";
    };
  };

  users.groups.thelessone = { };
  users.users.${config.config'.mainUserName}.extraGroups = [ "thelessone" ];

  environment.sessionVariables = {
    SSL_CERT_DIR = "/etc/ssl/certs";
  };
}
