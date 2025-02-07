{ config, username, ... }:

{
  hm.sec."private_keys/id_ume" = {
    sopsFile = ./yuri.yaml;
    format = "yaml";
    path = "${config.hm.home.homeDirectory}/.ssh/id_ume";
  };

  hm.home.file.".ssh/id_ume.pub".source = ./keys/id_ume.pub;

  sec."yubikeys/u2f_keys" = {
    sopsFile = ./yuri.yaml;
    format = "yaml";

    owner = username;
    inherit (config.users.users.${username}) group;
    path = "${config.hm.xdg.configHome}/Yubico/u2f_keys";
  };
}
