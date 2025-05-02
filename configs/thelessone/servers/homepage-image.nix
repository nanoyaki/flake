{
  pkgs,
  config,
  username,
  ...
}:

let
  dir = "/var/lib/caddy/homepage-images";
  group = "homepage-images";
in

{
  services.caddy.virtualHosts."homepage-images.theless.one".extraConfig = ''
    root * ${dir}
    file_server * browse
  '';

  systemd.services.homepage-dashboard-rotating-images = {
    wantedBy = [ "homepage-dashboard.service" ];

    path = with pkgs; [
      coreutils
      findutils
    ];

    script = ''
      MAX_ROTATION=$(find ${dir} -maxdepth 1 -type f | wc -l)

      CURRENT_ACTIVE="${dir}/active.webp"
      if [[ -L "$CURRENT_ACTIVE" ]]; then
        CURRENT_TARGET=$(readlink -f "$CURRENT_ACTIVE")
        CURRENT_NUM=$(basename "$CURRENT_TARGET" | grep -oE '[0-9]+' || echo "1")
        NEXT_NUM=$(( (CURRENT_NUM % MAX_ROTATION) + 1 ))
      else
        NEXT_NUM=1  # Start with 1 if no active link exists
      fi

      NEW_TARGET="${dir}/$NEXT_NUM.webp"
      NEW_LINK="${dir}/active.webp"

      ln -sf "$NEW_TARGET" "$NEW_LINK"
    '';

    startAt = "*:0/30";

    serviceConfig = {
      Type = "simple";
      Restart = "no";
    };
  };

  users.users.${username}.extraGroups = [ group ];
  users.users.${config.services.caddy.user}.extraGroups = [ group ];
  users.groups.${group} = { };

  systemd.tmpfiles.settings."10-homepage".${dir}.d = {
    inherit (config.services.caddy) user;
    inherit group;
    mode = "2770";
  };
}
