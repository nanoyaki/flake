{
  lib,
  lib',
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    optionalString
    ;

  inherit (lib') mkEnabledOption;

  service = "homepage-images";

  cfg = config.services.${service};

  subdomain = optionalString cfg.useSubdomain "${cfg.subdomain}.";
  slug = optionalString cfg.useDomainSlug "/${cfg.domainSlug}";
  inherit (config.services.caddy-easify) baseDomain;
  scheme = if config.services.caddy-easify.useHttps then "https://" else "http://";

  domain = "${scheme}${subdomain}${baseDomain}${slug}";
in

{
  options.services.${service} = {
    enable = mkEnabledOption "a homepage dashboard wallpaper slideshow";

    useSubdomain = mkEnabledOption "a subdomain for ${service}";

    subdomain = mkOption {
      type = types.str;
      default = service;
    };

    useDomainSlug = mkEnableOption "the domain slug for ${service}";

    domainSlug = mkOption {
      type = types.str;
      default = service;
    };

    group = mkOption {
      type = types.str;
      default = service;
    };

    directory = mkOption {
      type = types.path;
      default = "/var/lib/caddy/${service}";
    };
  };

  config = {
    services.caddy.virtualHosts.${domain}.extraConfig = ''
      root * ${cfg.directory}
      file_server * browse
    '';

    systemd.services.${service} = {
      after = [ "homepage-dashboard.service" ];

      bindsTo = [ "homepage-dashboard.service" ];
      partOf = [ "homepage-dashboard.service" ];

      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [
        coreutils
        findutils
      ];

      script = ''
        MAX_ROTATION=$(find ${cfg.directory} -maxdepth 1 -type f | wc -l)

        CURRENT_ACTIVE="${cfg.directory}/active.webp"
        if [[ -L "$CURRENT_ACTIVE" ]]; then
          CURRENT_TARGET=$(readlink -f "$CURRENT_ACTIVE")
          CURRENT_NUM=$(basename "$CURRENT_TARGET" | grep -oE '[0-9]+' || echo "1")
          NEXT_NUM=$(( (CURRENT_NUM % MAX_ROTATION) + 1 ))
        else
          NEXT_NUM=1  # Start with 1 if no active link exists
        fi

        ln -sf "${cfg.directory}/$NEXT_NUM.webp" "${cfg.directory}/active.webp"
      '';

      startAt = "*:0/30";

      serviceConfig = {
        Type = "simple";
        RemainAfterExit = false;
        Restart = "no";
      };
    };

    users.users.${config.services.caddy.user}.extraGroups = [ cfg.group ];
    users.groups = mkIf (cfg.group == service) {
      ${cfg.group} = { };
    };

    systemd.tmpfiles.settings."10-${service}".${cfg.directory}.d = {
      inherit (config.services.caddy) user;
      inherit (cfg) group;
      mode = "2770";
    };
  };
}
