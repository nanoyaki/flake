{
  lib,
  lib',
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib'.options)
    mkDefault
    mkStrOption
    mkPathOption
    mkFalseOption
    ;

  cfg = config.config'.lab-config;
in

{
  options.config'.lab-config = {
    enable = mkFalseOption;

    arr = {
      group = mkDefault "arr-stack" mkStrOption;
      home = mkDefault "/home/arr-stack" mkPathOption;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      wireguard-private = { };
      wireguard-address = { };
      wireguard-public = { };
      wireguard-endpoint = { };
    };

    sops.templates."wireguard.conf" = {
      file = (pkgs.formats.ini { }).generate "wireguard.conf" {
        Interface = {
          # Honest Puffer
          PrivateKey = config.sops.placeholder.wireguard-private;
          Address = config.sops.placeholder.wireguard-address;
          DNS = "10.64.0.1";
        };

        Peer = {
          PublicKey = config.sops.placeholder.wireguard-public;
          AllowedIPs = "0.0.0.0/0,::0/0";
          Endpoint = config.sops.placeholder.wireguard-endpoint;
        };
      };
      owner = "vopono";
      restartUnits = [ "vopono.service" ];
    };

    config'.vopono = {
      configFile = config.sops.templates."wireguard.conf".path;
      protocol = "Wireguard";
    };

    users.groups = mkIf (cfg.arr.group == "arr-stack") { arr-stack = { }; };
    users.users.${config.config'.mainUserName}.extraGroups = lib.singleton cfg.arr.group;
  };
}
