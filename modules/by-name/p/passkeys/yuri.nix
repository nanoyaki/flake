{
  lib,
  lib',
  config,
  ...
}:

{
  options.config'.yubikey.yuri.enable = lib'.options.mkFalseOption;

  config = lib.mkIf config.config'.yubikey.yuri.enable {
    hm = {
      sops.secrets = {
        "private_keys/id_nadesiko" = {
          sopsFile = ./yuri.yaml;
          format = "yaml";
          path = "${config.hm.home.homeDirectory}/.ssh/id_nadesiko";
        };

        "yubikeys/u2f_keys" = {
          sopsFile = ./yuri.yaml;
          format = "yaml";
          path = "${config.hm.xdg.configHome}/Yubico/u2f_keys";
        };
      };

      home.file.".ssh/id_nadesiko.pub".source = ./keys/id_nadesiko.pub;
    };
  };
}
