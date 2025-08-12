{ pkgs, config, ... }:

{
  sops.secrets = {
    "fireshare/secret-key" = { };
    "fireshare/admin-username" = { };
    "fireshare/admin-password" = { };
  };

  sops.templates."fireshare.env".file =
    (pkgs.formats.keyValue { }).generate "fireshare.env.template"
      {
        ADMIN_USERNAME = config.sops.placeholder."fireshare/admin-username";
        ADMIN_PASSWORD = config.sops.placeholder."fireshare/admin-password";
        SECRET_KEY = config.sops.placeholder."fireshare/secret-key";
      };

  config'.fireshare = {
    enable = true;
    backendListenAddress = "127.0.0.1:32254";
    dataDir = "/mnt/raid/fireshare";
    environment = {
      DOMAIN = "fireshare.theless.one";
    };

    environmentFile = config.sops.templates."fireshare.env".path;
  };

  config'.homepage.categories.Media.services.Fireshare = rec {
    description = "Clip sharing application";
    icon = "fireshare.svg";
    href = "https://fireshare.theless.one";
    siteMonitor = href;
  };
}
