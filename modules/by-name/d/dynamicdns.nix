{
  lib,
  lib',
  config,
  pkgs,
  ...
}:

let
  inherit (lib) nameValuePair mapAttrs' mkIf;
  inherit (lib'.options)
    mkAttrsOf
    mkListOf
    mkStrOption
    mkSubmoduleOption
    mkPathOption
    mkFalseOption
    ;

  cfg = config.config'.dynamicdns;
in

{
  options.config'.dynamicdns = {
    enable = mkFalseOption;

    domains = mkAttrsOf (mkSubmoduleOption {
      subdomains = mkListOf mkStrOption;
      passwordFile = mkPathOption;
    });
  };

  config = mkIf cfg.enable {
    systemd.services = mapAttrs' (
      domain: domainCfg:
      let
        inherit (domainCfg) passwordFile;

        subdomains = builtins.concatStringsSep " " domainCfg.subdomains;
      in
      nameValuePair "dynamicdns-${domain}" {
        description = "Dynamic DNS Service for ${domain}";

        after = [ "network-online.target" ];

        bindsTo = [ "network-online.target" ];
        partOf = [ "network-online.target" ];

        wantedBy = [ "multi-user.target" ];

        path = with pkgs; [
          coreutils-full
          curl
        ];

        script = ''
          set -f

          domain="${domain}"
          subdomains="${subdomains}"
          password=$(cat ${passwordFile})
          ip=$(curl "https://am.i.mullvad.net/ip" --fail)

          for subdomain in ''${subdomains}; do
            curl "https://dynamicdns.park-your-domain.com/update?host=$subdomain&domain=$domain&password=$password&ip=$ip" --fail
          done
        '';

        startAt = "*:0/20";

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = false;
          Restart = "no";
        };
      }
    ) cfg.domains;
  };
}
