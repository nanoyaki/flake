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
        path = "${config.users.users.${config.nanoSystem.mainUserName}.home}/.config/Yubico/u2f_keys";
        owner = config.nanoSystem.mainUserName;
        mode = "400";
      };
    };

    hm.home.file."${
      config.users.users.${config.nanoSystem.mainUserName}.home
    }/.ssh/id_nadesiko.pub".source =
      ./keys/id_nadesiko.pub;
  };
}
