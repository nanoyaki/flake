{
  self,
  lib,
  pkgs,
  config,
  ...
}:

{
  imports = [ self.nixosModules.shoko ];

  services.shoko = {
    enable = true;
    plugins = [ pkgs.shokofin ];
  };

  systemd.services.shoko.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "shoko";
    Group = config.services'.lab-config.arr.group;
  };

  users.users.shoko = {
    isSystemUser = true;
    inherit (config.services'.lab-config.arr) group;
    home = config.systemd.services.shoko.environment.SHOKO_HOME;
    homeMode = builtins.toString config.systemd.services.shoko.serviceConfig.StateDirectoryMode;
  };

  services'.caddy.reverseProxies."shoko.vpn.theless.one" = {
    port = 8111;
    vpnOnly = true;
  };

  services'.homepage.categories."Media services".services.Shoko = rec {
    description = "Anime manager";
    icon = "shoko.svg";
    href = "https://shoko.vpn.theless.one";
    siteMonitor = href;
  };

  users.users.torrent-copy = {
    isSystemUser = true;
    inherit (config.services'.lab-config.arr) group;
  };

  systemd.services.torrent-copy = {
    description = "Copies completed torrents once for shoko.";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    path = with pkgs; [
      inotify-tools
      gawk
    ];

    script = ''
      WATCH_DIR="/mnt/raid/arr-stack/downloads/transmission/complete/shoko"
      DEST_DIR="/mnt/raid/arr-stack/downloads/shoko"
      STATE_FILE="/var/lib/torrent-copy/processed.log"

      touch "$STATE_FILE"

      process_path() {
        local filepath="$1"
        local relative_path="''${filepath#"$WATCH_DIR/"}"
        local dest_path="$DEST_DIR/$relative_path"

        if grep -Fxq "$relative_path" "$STATE_FILE"; then
          return 0
        fi

        cp -r -- "$filepath" "$dest_path"
        chmod 2770 -R "$dest_path"

        echo "$relative_path" >> "$STATE_FILE"
        echo "Copied: $relative_path"
      }

      inotifywait -m -r -e create -e moved_to --format '%w%f' "$WATCH_DIR" | while read -r filepath
      do
        if [[ "$filepath" =~ .*__[a-zA-Z0-9]{6}$ ]]; then
          return 0
        fi

        process_path "$filepath"
      done
    '';

    serviceConfig = {
      User = "root";
      Group = "wheel";
      Restart = "always";
      RestartSec = "10s";
      StateDirectory = "torrent-copy";
      StateDirectoryMode = "700";
      Type = "simple";
    };
  };
}
