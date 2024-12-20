{ config, ... }:

{
  sec."nixos/users/hana".owner = "hana";

  users.users.nas.extraGroups = [ "nas" ];
  users.groups.nas = { };

  users.groups.hana = { };
  users.users.hana = {
    isNormalUser = true;
    group = "hana";
    createHome = false;
    home = "/mnt/shares/Hana";
    homeMode = "755";
    useDefaultShell = true;
    hashedPasswordFile = config.sec."nixos/users/hana".path;
  };

  systemd.tmpfiles.settings."10-samba" = {
    "/mnt/shares/Public".d = {
      user = "nas";
      group = "nas";
      mode = "0755";
    };

    "/mnt/shares/Hana".d = {
      user = "hana";
      group = "hana";
      mode = "0755";
    };
  };

  services.samba = {
    enable = true;
    openFirewall = true;

    settings = {
      global = {
        security = "user";
        "netbios name" = "home-nas";
        "server string" = "NixOS NAS";

        "hosts allow" = "192.168.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";

        "guest account" = "nobody";
        "map to guest" = "bad user";
      };

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

      hana = {
        path = "/mnt/shares/Hana";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "hana";
        "force group" = "hana";
        "valid users" = "hana";
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
