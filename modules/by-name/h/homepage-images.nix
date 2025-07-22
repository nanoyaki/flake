{
  lib,
  lib',
  config,
  ...
}:

let
  inherit (lib'.options)
    mkDefault
    mkStrOption
    mkPathOption
    mkIntOption
    mkFalseOption
    ;

  inherit (builtins) toString;

  cfg = config.config'.homepage-images;
  domain = config.config'.caddy.genDomain cfg.subdomain;
in

{
  options.config'.homepage-images = {
    enable = mkFalseOption;

    subdomain = mkDefault "homepage-images" mkStrOption;

    group = mkDefault "homepage-images" mkStrOption;
    dataDir = mkDefault "${config.services.caddy.dataDir}/homepage-images" mkPathOption;
    refreshDuration = mkDefault 5 mkIntOption;
  };

  config = lib.mkIf cfg.enable {
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      root * ${cfg.dataDir}
      file_server * browse

      header Cache-Control "max-age=${toString (cfg.refreshDuration * 60)}, must-revalidate, public"
    '';

    systemd.services.homepage-images = {
      after = [ "homepage-dashboard.service" ];

      bindsTo = [ "homepage-dashboard.service" ];
      partOf = [ "homepage-dashboard.service" ];

      wantedBy = [ "multi-user.target" ];

      script = ''
        MAX_ROTATION=$(find ${cfg.dataDir} -maxdepth 1 -type f | wc -l)

        NEXT_NUM=1
        CURRENT_ACTIVE="${cfg.dataDir}/active.webp"
        if [[ -L "$CURRENT_ACTIVE" ]]; then
          CURRENT_TARGET=$(readlink -f "$CURRENT_ACTIVE")
          CURRENT_NUM=$(basename "$CURRENT_TARGET" | grep -oP '\d+' || echo "1")
          NEXT_NUM=$(( (CURRENT_NUM % MAX_ROTATION) + 1 ))
        fi

        ln -sf "${cfg.dataDir}/$NEXT_NUM.webp" "${cfg.dataDir}/active.webp"
      '';

      startAt = "*:0/${toString cfg.refreshDuration}";

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
        Restart = "no";
      };
    };

    users.users.${config.services.caddy.user}.extraGroups = [ cfg.group ];
    users.groups = lib.mkIf (cfg.group == "homepage-images") { homepage-images = { }; };

    systemd.tmpfiles.settings."10-homepage-images".${cfg.dataDir}.d = {
      inherit (config.services.caddy) user;
      inherit (cfg) group;
      mode = "2770";
    };
  };
}
