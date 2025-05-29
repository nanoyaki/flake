{
  lib,
  lib',
  ...
}:

let
  inherit (lib'.options) mkDefault mkStrOption mkPathOption;
in

lib'.modules.mkModule {
  name = "homepage-images";

  options =
    { config, ... }:

    {
      group = mkDefault "homepage-images" mkStrOption;
      dataDir = mkDefault "${config.services.caddy.dataDir}/homepage-images" mkPathOption;
    };

  config =
    {
      cfg,
      config,
      helpers',
      ...
    }:

    {
      services.caddy.virtualHosts.${helpers'.caddy.domain cfg}.extraConfig = ''
        root * ${cfg.dataDir}
        file_server * browse
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

        startAt = "*:0/30";

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

  dependencies = [ "caddy" ];
}
