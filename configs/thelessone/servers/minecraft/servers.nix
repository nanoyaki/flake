{
  lib,
  inputs,
  pkgs,
  config,
  ...
}:

let
  defaults = {
    autoStart = true;
    jvmOpts = "-Xms32G -Xmx32G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";

    serverProperties = {
      spawn-protection = 0;
      view-distance = 12;
      simulation-distance = 12;

      gamemode = "survival";
      difficulty = "hard";

      white-list = true;
    };

    operators.nanoyaki = "433b63b5-5f77-4a9f-b834-8463d520500c";

    whitelist = import ./whitelist.nix;
  };

  writeJSON = (pkgs.formats.json { }).generate;
  writeHocon = (pkgs.formats.hocon { }).generate;
in

{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  sec."minecraft/botToken" = { };

  sops.templates."discord-mc-chat.json" = {
    file = writeJSON "discord-mc-chat.json" {
      generic = {
        language = "en_us";
        botToken = config.sops.placeholder."minecraft/botToken";
        channelId = "1395405287984201738";
        adminsIds = [
          "1063583541641871440"
          "222458973876387841"
        ];

        avatarApi = "https://visage.surgeplay.com/bust/{player_uuid}.png";
        broadcastPlayerCommandExecution = false;
        broadcastSlashCommandExecution = false;
        whitelistRequiresAdmin = false;
        announceHighMspt = false;
        excludedCommands = [ ".*" ];
      };
    };
    path = "${config.services.minecraft-servers.dataDir}/smp/config/discord-mc-chat.json";
    owner = config.services.minecraft-servers.user;
    restartUnits = [ "minecraft-server-smp.service" ];
  };

  services.minecraft-servers = {
    enable = true;
    eula = true;

    openFirewall = true;

    servers.smp = lib.recursiveUpdate defaults {
      enable = true;
      package = pkgs.fabricServers.fabric-1_21_7;

      serverProperties.server-port = 25565;

      symlinks = {
        mods = pkgs.callPackage ./mods.nix { };

        "config/voicechat/voicechat-server.properties" =
          (pkgs.formats.keyValue { }).generate "voicechat-server.properties"
            {
              port = 25566;
              bind_address = "";
              max_voice_distance = 64.0;
              crouch_distance_multiplier = 0.75;
              whisper_distance_multiplier = 0.5;
              codec = "VOIP";
              mtu_size = 1024;
              keep_alive = 1000;
              enable_groups = true;
              voice_host = "theless.one:25566";
              allow_recording = true;
              spectator_interaction = false;
              spectator_player_possession = false;
              force_voice_chat = false;
              login_timeout = 10000;
              broadcast_range = -1.0;
              allow_pings = true;
            };

        "config/bluemap/core.conf" = writeHocon "core.conf" {
          accept-download = true;
          scan-for-mod-resources = true;
          data = "bluemap";
          render-thread-count = 12;
          metrics = false;
          log.file = "logs/bluemap.log";
          log.append = true;
        };

        "config/bluemap/plugin.conf" = writeHocon "plugin.conf" {
          live-player-markers = true;
          hidden-game-modes = [ "spectator" ];
          hide-vanished = true;
          hide-invisible = true;
          hide-sneaking = true;
          hide-below-sky-light = 0;
          hide-below-block-light = 0;
          hide-different-world = false;
          skin-download = true;
          player-render-limit = -1;
          full-update-interval = 720;
        };

        "config/bluemap/webapp.conf" = writeHocon "webapp.conf" {
          enabled = true;
          webroot = "bluemap/web";
          update-settings-file = true;
          use-cookies = true;
          enable-free-flight = true;
          default-to-flat-view = false;
          min-zoom-distance = 5;
          max-zoom-distance = 100000;
          resolution-default = 1;

          hires-slider-max = 500;
          hires-slider-default = 100;
          hires-slider-min = 0;

          lowres-slider-max = 7000;
          lowres-slider-default = 2000;
          lowres-slider-min = 500;

          scripts = [ ];
          styles = [ ];
        };

        "config/bluemap/webserver.conf" = writeHocon "webserver.conf" {
          enabled = true;
          webroot = "bluemap/web";
          port = 8100;

          log = {
            file = "logs/bluemap.log";
            append = true;
            format = "%1$s \"%3$s %4$s %5$s\" %6$s %7$s";
          };
        };

        "config/roles.json" = writeJSON "roles.json" {
          whitelister.overrides.commands."whitelist (add|remove)" = "allow";
          everyone.overrides.commands = {
            "image2map create" = "allow";
            "tick query" = "allow";
          };
        };

        "icon.png" = ./icon.png;
      };
    };
  };

  services'.caddy.reverseProxies."map.theless.one".port = 8100;
}
