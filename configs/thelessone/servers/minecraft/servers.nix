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
      view-distance = 32;
      simulation-distance = 32;

      gamemode = "survival";
      difficulty = "normal";

      white-list = true;
    };

    operators.nanoyaki = "433b63b5-5f77-4a9f-b834-8463d520500c";

    whitelist = import ./whitelist.nix;
  };

  writeJSON = (pkgs.formats.json { }).generate;
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
      };
    };
    path = "${config.services.minecraft-servers.dataDir}/smp/config/discord-mc-chat.json";
    owner = config.services.minecraft-servers.user;
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

        "config/voicechat/voicechat-server.properties" = ./smp/voicechat-server.properties;

        "config/bluemap/core.conf" = ./smp/bluemap/core.conf;
        "config/bluemap/plugin.conf" = ./smp/bluemap/plugin.conf;
        "config/bluemap/webapp.conf" = ./smp/bluemap/webapp.conf;
        "config/bluemap/webserver.conf" = ./smp/bluemap/webserver.conf;

        "config/roles.json" = writeJSON "roles.json" {
          whitelister.overrides.commands."whitelist (add|remove)" = "allow";
          everyone.overrides.commands = {
            "image2map create" = "allow";
            "tick query" = "allow";
          };
        };
      };
    };
  };

  services'.caddy.reverseProxies."map.theless.one".port = 8100;
}
