{ config, ... }:

{
  sops.secrets."users/hana".neededForUsers = true;
  sops.secrets."users/hana-smb" = { };

  users.groups.nas = { };
  users.users.nas.extraGroups = [ "nas" ];

  users.users.hana = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets."users/hana".path;
    extraGroups = [ "nas" ];

    home = "/mnt/nvme-raid-1/shares/Hana";
    homeMode = "700";
  };

  systemd.tmpfiles.settings."10-samba"."/mnt/nvme-raid-1/shares/Public".d = {
    user = "nas";
    group = "nas";
    mode = "0755";
  };

  services.samba = {
    enable = true;
    openFirewall = true;

    settings = {
      global = {
        "log level" = 1;
        "logging" = "systemd";

        "netbios name" = "NAS";
        "server string" = "NAS";

        "hosts allow" = "10.0.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";

        security = "user";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };

      public = {
        path = "/mnt/nvme-raid-1/shares/Public";

        public = "yes";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";

        "create mask" = "0644";
        "directory mask" = "0755";

        "force user" = "nas";
        "force group" = "nas";
      };

      hana = {
        path = "/mnt/nvme-raid-1/shares/Hana";

        browseable = "yes";
        writable = "yes";
        "read only" = "no";
        "guest ok" = "no";

        "create mask" = "0640";
        "directory mask" = "0750";

        "valid users" = "hana";
        "force user" = "hana";
        "force group" = "users";
      };
    };
  };

  systemd.services.samba-smbd.postStart = ''
    ( \
      echo $(< ${config.sops.secrets."users/hana-smb".path}); \
      echo $(< ${config.sops.secrets."users/hana-smb".path}) \
    ) | ${config.services.samba.package}/bin/smbpasswd -s -a hana
  '';

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.avahi = {
    enable = true;
    openFirewall = true;

    publish.enable = true;
    publish.userServices = true;

    nssmdns4 = true;
  };
}
