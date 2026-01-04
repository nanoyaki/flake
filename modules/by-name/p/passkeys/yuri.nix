{
  lib,
  lib',
  config,
  ...
}:

{
  options.config'.yubikey.yuri.enable = lib'.options.mkFalseOption;

  config = lib.mkIf config.config'.yubikey.yuri.enable {
    sops.secrets = {
      "private_keys/id_nadesiko" = {
        sopsFile = ./yuri.yaml;
        format = "yaml";
        path = "${config.users.users.${config.nanoSystem.mainUserName}.home}/.ssh/id_nadesiko";
        owner = config.nanoSystem.mainUserName;
        mode = "400";
      };

      "yubikeys/u2f_keys" = {
        sopsFile = ./yuri.yaml;
        format = "yaml";
        owner = config.nanoSystem.mainUserName;
        mode = "400";
      };
    };

    hm.home.file."${
      config.users.users.${config.nanoSystem.mainUserName}.home
    }/.ssh/id_nadesiko.pub".source =
      ./keys/id_nadesiko.pub;

    security.pam.u2f = {
      enable = true;
      settings = {
        cue = true;
        authfile = config.sops.secrets."yubikeys/u2f_keys".path;
      };
    };

    security.pam.services = {
      login.u2fAuth = true;
      sudo = {
        u2fAuth = true;
        sshAgentAuth = true;
      };
    };
  };
}
