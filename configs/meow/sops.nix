{
  lib,
  inputs,
  config,
  ...
}:

let
  inherit (inputs) sops-nix;
in

{
  imports = [
    sops-nix.homeManagerModules.sops
    (lib.mkAliasOptionModule
      [ "sec" ]
      [
        "sops"
        "secrets"
      ]
    )
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };

  sec = {
    "private_keys/id_nadesiko" = {
      sopsFile = ../common/optional/passkeys/yuri.yaml;
      format = "yaml";
      path = "${config.home.homeDirectory}/.ssh/id_nadesiko";
    };

    "yubikeys/u2f_keys" = {
      sopsFile = ../common/optional/passkeys/yuri.yaml;
      format = "yaml";
      path = "${config.xdg.configHome}/Yubico/u2f_keys";
    };
  };

  home.file.".ssh/id_nadesiko.pub".source = ../common/optional/passkeys/keys/id_nadesiko.pub;
}
