{ config, ... }:

{
  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.tailscale ];

    services.tailscale.thelessone.enable = true;
  };

  modules.nixos.tailscale =
    { lib, config, ... }:

    let
      inherit (lib)
        mkEnableOption
        mkOption
        types
        mkMerge
        mkIf
        ;

      cfg = config.services.tailscale;
    in

    {
      options.services.tailscale.thelessone = {
        enable = mkEnableOption "the thelessone non-interactive authenticated network connection";

        keyFile = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = ''
            The path to the *permanent* headscale preauth-key required to authenticate.
          '';
        };
      };

      config = mkMerge [
        {
          services.tailscale = {
            enable = true;
            useRoutingFeatures = "server";
            extraUpFlags = [ "--advertise-exit-node" ];
          };
        }
        (mkIf cfg.thelessone.enable {
          services.tailscale.authKeyFile = cfg.thelessone.keyFile;
          services.tailscale.extraUpFlags = [
            "--login-server=https://headscale.nanoyaki.space"
            "--force-reauth"
            "--accept-dns=true"
          ];
        })
      ];
    };

  modules.nixos.sops =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.services.tailscale.thelessone.enable {
        sops.secrets.tailscale.sopsFile = ./secrets.yaml;
        services.tailscale.thelessone.keyFile = config.sops.secrets.tailscale.path;
      };
    };
}
