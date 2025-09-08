{
  lib,
  lib',
  pkgs,
  config,
  ...
}:

let
  inherit (lib'.options)
    mkDefault
    mkAttrsOf
    mkEither
    mkListOf
    mkStrOption
    mkPortOption
    mkPathOption
    mkEnumOption
    mkFalseOption
    ;

  inherit (lib) mkPackageOption getExe' mkIf;
  inherit (lib.lists) singleton unique flatten;
  inherit (lib.attrsets) attrValues mapAttrs;
  inherit (lib.strings) concatMapStrings;

  cfg = config.config'.vopono;
in

{
  options.config'.vopono = {
    enable = mkFalseOption;

    package = mkPackageOption pkgs "vopono" { };
    dataDir = mkDefault "/var/lib/vopono" mkPathOption;
    configFile = mkPathOption;
    protocol = mkEnumOption [
      "Wireguard"
      "OpenVPN"
    ];
    interface = mkStrOption;
    namespace = mkDefault "vopono0" mkStrOption;
    services = mkAttrsOf (mkEither mkPortOption (mkListOf mkPortOption));
    allowedTCPPorts = mkListOf mkPortOption;
    allowedUDPPorts = mkListOf mkPortOption;

    host = mkDefault "10.200.1.2" mkStrOption;
    vpnHost = mkDefault "10.200.1.1" mkStrOption;
  };

  config = mkIf cfg.enable {
    users.users.vopono = {
      isSystemUser = true;
      group = "vopono";
      home = cfg.dataDir;
    };

    users.groups.vopono = { };

    systemd.tmpfiles.settings."10-vopono-config"."${cfg.dataDir}/.config/vopono".d = {
      user = "vopono";
      group = "vopono";
      mode = "770";
    };

    networking.firewall.interfaces."${cfg.namespace}_d" = {
      inherit (cfg)
        allowedTCPPorts
        allowedUDPPorts
        ;
    };

    systemd.services = {
      vopono = {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        path = [
          "/run/wrappers"
          cfg.package
        ]
        ++ (with pkgs; [
          wireguard-tools
          iproute2
          iptables
          procps
          systemd
        ]);

        unitConfig.ConditionPathExists = "${cfg.dataDir}/.config/vopono";

        script = ''
          vopono exec \
            ${lib.optionalString (cfg.interface != "") "-i ${cfg.interface}"} \
            -u vopono \
            --keep-alive \
            ${concatMapStrings (port: "-f ${toString port} ") (unique (flatten (attrValues cfg.services)))} \
            ${
              concatMapStrings (port: "-o ${toString port} ") (
                unique (cfg.allowedTCPPorts ++ cfg.allowedUDPPorts)
              )
            } \
            --allow-host-access \
            --custom ${cfg.configFile} \
            --protocol ${cfg.protocol} \
            --custom-netns-name ${cfg.namespace} \
            "systemd-notify --ready"
        '';

        serviceConfig = {
          Type = "notify";
          NotifyAccess = "all";
          Restart = "on-failure";
          RestartSec = "5s";

          ExecStop = "${getExe' pkgs.iproute2 "ip"} link delete ${cfg.namespace}_d";

          User = "vopono";
          Group = "vopono";
        };
      };
    }
    // mapAttrs (_: _: {
      after = [ "vopono.service" ];
      bindsTo = [ "vopono.service" ];
      partOf = [ "vopono.service" ];

      serviceConfig = {
        BindPaths = [ "/etc/netns/${cfg.namespace}/resolv.conf:/etc/resolv.conf" ];
        NetworkNamespacePath = "/var/run/netns/${cfg.namespace}";
      };
    }) cfg.services;

    security.sudo.extraRules = singleton {
      users = singleton "vopono";
      commands = singleton {
        command = "ALL";
        options = singleton "NOPASSWD";
      };
    };
  };
}
