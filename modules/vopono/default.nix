{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    nameValuePair
    mkIf
    mkMerge
    concatMapStrings
    mkPackageOption
    ;

  inherit (lib.lists) unique flatten;

  inherit (builtins)
    listToAttrs
    attrValues
    toString
    attrNames
    ;

  cfg = config.services.vopono;
in
{

  options = {
    services.vopono = {
      enable = mkEnableOption "vopono service";

      package = mkPackageOption pkgs "vopono" { };

      configFile = mkOption {
        description = "Custom configuration file to pass as --custom to vopono.";
        type = types.path;
        example = "/run/secrets/wireguard.conf";
      };

      protocol = mkOption {
        description = "One of either Wireguard or OpenVPN.";
        type = types.enum [
          "Wireguard"
          "OpenVPN"
        ];
        example = "Wireguard";
      };

      interface = mkOption {
        type = types.str;
        default = "";
        description = "Optionally define the default interface. If not set, it uses the first interface on the system.";
      };

      namespace = mkOption {
        type = types.str;
        default = "sys_vo";
        example = "vopono";
        description = "Override the default, auto generated, namespace.";
      };

      services = mkOption {
        default = { };
        type = types.attrsOf (types.either types.port (types.listOf types.port));
        description = ''An attribute set with the name of a service where the value is a list of ports to forward to it.'';
        example = lib.literalExpression ''
          { privoxy = [ 8118 ]; }
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      systemd.tmpfiles.settings."10-vopono-config"."/root/.config/vopono".d = {
        user = "root";
        group = "wheel";
        mode = "770";
      };

      systemd.services.vopono = {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        path = with pkgs; [
          cfg.package
          wireguard-tools
          iproute2
          iptables
          procps
          systemd
          sudo
        ];

        unitConfig.ConditionPathExists = "/root/.config/vopono";

        serviceConfig = {
          Type = "notify";
          NotifyAccess = "all";
          Restart = "always";
          RestartSec = "5s";

          ExecStart = pkgs.writeShellScript "vopono-start.sh" ''
            ${lib.getExe cfg.package} exec \
              ${lib.optionalString (cfg.interface != "") "-i ${cfg.interface}"} -u root \
              --keep-alive \
              ${concatMapStrings (x: " -f ${toString x}") (unique (flatten (attrValues cfg.services)))} \
              --allow-host-access \
              --custom ${cfg.configFile} \
              --protocol ${cfg.protocol} \
              --custom-netns-name ${cfg.namespace} \
              "systemd-notify --ready"
          '';
          ExecStop = "${pkgs.iproute2}/bin/ip link delete ${cfg.namespace}_d";
        };
      };
    })

    {
      systemd.services = listToAttrs (
        map (
          service:
          nameValuePair service {
            after = [ "vopono.service" ];
            partOf = [ "vopono.service" ];
            wantedBy = [ "vopono.service" ];
            serviceConfig = {
              BindPaths = [ "/etc/netns/${cfg.namespace}/resolv.conf:/etc/resolv.conf" ];
              NetworkNamespacePath = "/var/run/netns/${cfg.namespace}";
            };
          }
        ) (attrNames cfg.services)
      );
    }
  ];
}
