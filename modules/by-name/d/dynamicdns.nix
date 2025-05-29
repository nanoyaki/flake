{
  lib,
  lib',
  ...
}:

let
  inherit (lib'.options)
    mkAttrsOf
    mkListOf
    mkStrOption
    mkSubmoduleOption
    mkPathOption
    ;

  inherit (lib) nameValuePair mapAttrs';
in

lib'.modules.mkModule {
  name = "dynamicdns";

  options.domains = mkAttrsOf (mkSubmoduleOption {
    subdomains = mkListOf mkStrOption;
    passwordFile = mkPathOption;
  });

  config =
    {
      cfg,
      pkgs,
      ...
    }:

    {
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

          script = ''
            set -f

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
            Type = "oneshot";
            RemainAfterExit = false;
            Restart = "no";
          };
        }
      ) cfg.domains;
    };
}
