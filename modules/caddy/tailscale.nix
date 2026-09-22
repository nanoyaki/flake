{
  modules.nixos.tailscale =
    { lib, config, ... }:

    let
      inherit (lib)
        types
        mkOption
        mkEnableOption
        mkBefore
        mkIf
        all
        attrValues
        ;

      cfg = config.services.tailscale;
    in

    {
      options.services.caddy.virtualHosts = mkOption {
        type = types.attrsOf (
          types.submodule (
            { config, ... }:

            {
              options.tailnetOnly = mkEnableOption "tailnet and local access only";

              config = mkIf config.tailnetOnly {
                extraConfig = mkBefore ''
                  import tailnet-only
                '';
              };
            }
          )
        );
      };

      config = mkIf config.services.caddy.enable {
        assertions = [
          {
            assertion = all (hostCfg: cfg.thelessone.enable && hostCfg.tailnetOnly) (
              attrValues config.services.caddy.virtualHosts
            );
            message = ''
              {option}`services.caddy.virtualHosts.<name>.tailnetOnly` does not have any effect without
              enabling {option}`services.tailscale.thelessone.enable`
            '';
          }
        ];

        services.caddy.extraConfig = ''
          (tailnet-only) {
            @forbidden not client_ip 100.64.0.0/24 fd7a:115c:a1e0::/48 private_ranges 127.0.0.1/32 ::1/32

            handle @forbidden {
              error 404
            }
          }
        '';
      };
    };
}
