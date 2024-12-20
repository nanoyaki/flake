{
  users.users.nas.extraGroups = [ "nas" ];
  users.groups.nas = { };

  systemd.tmpfiles.settings."10-samba"."/mnt/shares/Public".d = {
    user = "nas";
    group = "nas";
    mode = "0755";
  };

  services.samba = {
    enable = true;
    openFirewall = true;

    settings = {
      global.security = "user";

      public = {
        path = "/mnt/shares/Public";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "nas";
        "force group" = "nas";
      };
    };
  };

  services.avahi = {
    enable = true;
    openFirewall = true;

    publish.enable = true;
    publish.userServices = true;

    nssmdns4 = true;
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
