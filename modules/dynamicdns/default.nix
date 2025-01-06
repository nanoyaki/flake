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
    systemd.services = mapAttrs' (
      domain: domainCfg:
      let
        inherit (domainCfg) passwordFile;

        subdomains = builtins.concatStringsSep " " domainCfg.subdomains;
      in
      nameValuePair "namecheap-dynamic-dns-${domain}" {
        description = "Namecheap Dynamic DNS Service for ${domain}";

        wantedBy = [ "multi-user.target" ];
        requires = [ "network-online.target" ];
        after = [ "network-online.target" ];

        script = ''
          domain="${domain}"
          subdomains="${subdomains}"
          password=$(${lib.getExe' pkgs.coreutils "cat"} ${passwordFile})
          ip=$(${lib.getExe pkgs.curl} "https://am.i.mullvad.net/ip" --fail)

          for subdomain in ''${subdomains}; do
            ${lib.getExe pkgs.curl} "https://dynamicdns.park-your-domain.com/update?host=$subdomain&domain=$domain&password=$password&ip=$ip" --fail
          done
        '';

        startAt = "*:0/20";

        serviceConfig = {
          Type = "simple";
          Restart = "no";
        };
      }
    ) cfg.domains;
  };
}
