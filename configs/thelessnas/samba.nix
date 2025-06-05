{
  systemd.tmpfiles.settings."10-samba"."/mnt/mass-storage".d = {
    user = "root";
    group = "wheel";
    mode = "770";
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "hosts allow" = "192.168.178. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
      };

      public = {
        path = "/mnt/mass-storage";
        "read only" = "no";
        browseable = "yes";
        "guest ok" = "yes";
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
    hostname = "NAS";
  };
}
