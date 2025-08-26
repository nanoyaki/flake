{
  lib,
  pkgs,
  config,
  ...
}:

{
  sops.secrets = {
    gokapi-salt-admin = { };
    gokapi-salt-files = { };
  };

  sops.templates."gokapi.json" = {
    file = (pkgs.formats.json { }).generate "gokapi.json.template" {
      Authentication = {
        HeaderKey = "";
        Method = 0;
        OAuthClientId = "";
        OAuthClientSecret = "";
        OAuthGroups = [ ];
        OAuthRecheckInterval = 12;
        OauthGroupScope = "";
        OauthProvider = "";
        OnlyRegisteredUsers = false;
        SaltAdmin = config.sops.placeholder.gokapi-salt-admin;
        SaltFiles = config.sops.placeholder.gokapi-salt-files;
        Username = "nanoyaki";
      };
      ChunkSize = 45;
      # Initial version, to be overwritten by gokapi
      ConfigVersion = 22;
      DataDir = "/mnt/raid/gokapi/data";
      DatabaseUrl = "sqlite:///mnt/raid/gokapi/data/gokapi.sqlite";
      Encryption = {
        Checksum = "";
        ChecksumSalt = "";
        Cipher = null;
        Level = 0;
        Salt = "";
      };
      IncludeFilename = false;
      MaxFileSizeMB = 102400;
      MaxMemory = 50;
      MaxParallelUploads = 4;
      PicturesAlwaysLocal = false;
      Port = ":${toString config.services.gokapi.environment.GOKAPI_PORT}";
      PublicName = "Gokapi";
      RedirectUrl = "https://vpn.theless.one/";
      SaveIp = false;
      ServerUrl = "https://gokapi.vpn.theless.one/";
      UseSsl = false;
    };
    owner = "gokapi";
  };

  services.gokapi = {
    enable = true;
    settingsFile = config.sops.templates."gokapi.json".path;
    environment = {
      GOKAPI_DATA_DIR = "/mnt/raid/gokapi/data";
      GOKAPI_CONFIG_DIR = "/mnt/raid/gokapi/config";
      GOKAPI_CONFIG_FILE = "config.json";
      GOKAPI_PORT = 56779;
    };
  };

  users.users.gokapi = {
    isSystemUser = true;
    group = "gokapi";
    home = "/mnt/raid/gokapi";
  };

  users.groups.gokapi = { };

  systemd.services.gokapi.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "gokapi";
    Group = "gokapi";
  };

  systemd.tmpfiles.settings."10-gokapi"."/mnt/raid/gokapi".d = {
    user = "gokapi";
    group = "gokapi";
    mode = "0750";
  };

  config'.caddy.reverseProxies."gokapi.vpn.theless.one" = {
    vpnOnly = true;
    port = config.services.gokapi.environment.GOKAPI_PORT;
  };

  config'.homepage.categories.Services.services.Gokapi = rec {
    description = "File sharing platform";
    icon = "https://files.theless.one/plasmavault.svg";
    href = "https://gokapi.vpn.theless.one/login";
    siteMonitor = href;
  };
}
