{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    mkEnableOption
    mkIf
    nameValuePair
    mapAttrs'
    ;

  cfg = config.services.namecheapDynDns;
in

{
  options.services.namecheapDynDns = {
    enable = mkEnableOption "dynamic dns";

    user = mkOption {
      type = types.str;
      default = "namecheapDynDns";
      description = "The user to use for the updater services";
    };

    group = mkOption {
      type = types.str;
      default = "namecheapDynDns";
      description = "The group to use for the updater services";
    };

    home = mkOption {
      type = types.str;
      default = "/var/lib/namecheapdyndns";
      description = "The namecheap dynamic dns user's home";
    };

    domains = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            subdomains = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "The subdomains to update.";
            };

            passwordFile = mkOption {
              type = types.str;
              description = "The path to the file containing the password for the namecheap dynamic dns service.";
            };
          };
        }
      );
    };
  };

  config = mkIf cfg.enable {
    users.groups = mkIf (cfg.group == "namecheapDynDns") { namecheapDynDns = { }; };

    users.users = mkIf (cfg.user == "namecheapDynDns") {
      namecheapDynDns = {
        inherit (cfg) home group;
        isSystemUser = true;
      };
    };

    systemd = {
      tmpfiles.settings."10-namecheapDynDns".${cfg.home}.d = {
        inherit (cfg) user group;
        mode = "0700";
      };

      services = mapAttrs' (
        domain: domainCfg:
        let
          inherit (domainCfg) passwordFile;

          subdomains = builtins.concatStringsSep " " domainCfg.subdomains;
        in
        nameValuePair "namecheapDynDns-${domain}" {
          description = "Namecheap Dynamic DNS Service for ${domain}";

          wantedBy = [ "multi-user.target" ];
          after = [
            "network.target"
          ];

          path = [
            pkgs.curl
          ];

          script = ''
            basedomain="${domain}"
            subdomains="${subdomains}"
            password=$(cat ${passwordFile})
            ip=$(curl -4 icanhazip.com --fail)

            for subdomain in ''${subdomains}; do
              curl "https://dynamicdns.park-your-domain.com/update?host=$subdomain&domain=$basedomain&password=$password&ip=$ip" --fail
            done
          '';

          startAt = "hourly";

          serviceConfig = {
            User = cfg.user;
            Group = cfg.group;

            Type = "simple";
            Restart = "no";

            WorkingDirectory = cfg.home;
          };
        }
      ) cfg.domains;

      timers = mapAttrs' (
        domain: _: nameValuePair "namecheapDynDns-${domain}" { timerConfig.RandomizedDelaySec = "30s"; }
      ) cfg.domains;
    };
  };
}
