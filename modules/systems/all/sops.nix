{
  lib,
  lib',
  pkgs,
  config,
  inputs,
  ...
}:

let
  inherit (lib)
    mkIf
    mapAttrs
    mapAttrs'
    nameValuePair
    ;
  inherit (lib'.options)
    mkTrueOption
    mkFalseOption
    mkPathOption
    mkDefault
    mkNullOr
    ;
  inherit (inputs) sops-nix;

  cfg = config.config'.sops;
in

{
  imports = [ sops-nix.nixosModules.sops ];

  options.config'.sops = {
    enable = mkTrueOption;
    useSharedFileAsDefault = mkFalseOption;
    sharedSopsFile = mkDefault ./secrets.yaml mkPathOption;
    # Defaults to <flake-root>/configs/<hostname>/secrets.yaml
    systemSpecificSopsFile = mkNullOr mkPathOption;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.sops ];

    sops = {
      defaultSopsFile =
        if !cfg.useSharedFileAsDefault then
          if cfg.systemSpecificSopsFile == null then
            (../../../configs + "/${config.networking.hostName}/secrets/host.yaml")
          else
            cfg.systemSpecificSopsFile
        else
          cfg.sharedSopsFile;
      defaultSopsFormat = "yaml";

      age.keyFile = "${config.hm.xdg.configHome}/sops/age/keys.txt";
      secrets = mapAttrs' (
        _: user: nameValuePair user.sopsKey { neededForUsers = true; }
      ) config.config'.users;
    };

    users.users = mapAttrs (_: user: {
      hashedPasswordFile = config.sops.secrets.${user.sopsKey}.path;
    }) config.config'.users;

    hms = [
      sops-nix.homeManagerModules.sops
      (
        { config, osConfig, ... }:

        {
          sops = {
            defaultSopsFile = lib.mkOptionDefault (
              ../../../configs + "/${osConfig.networking.hostName}/secrets/user-${config.home.username}.yaml"
            );
            defaultSopsFormat = "yaml";

            age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
          };
        }
      )
    ];

    security.pki.certificateFiles = [ ./ca.pem ];
  };
}
