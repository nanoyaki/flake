{
  inputs,
  pkgs,
  ...
}:

let
  defaults = {
    autoStart = true;
    enableReload = true;
    jvmOpts = "-Xms32G -Xmx32G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";

    serverProperties = {
      spawn-protection = 0;
      view-distance = 32;
      simulation-distance = 32;

      gamemode = "survival";
      difficulty = "normal";
    };

    operators.nanoyaki = "433b63b5-5f77-4a9f-b834-8463d520500c";
  };
in

{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;

    openFirewall = true;

    servers.smp = {
      enable = false;
      package = pkgs.fabricServers.fabric-1_21_1;
      inherit (defaults)
        autoStart
        enableReload
        jvmOpts
        operators
        ;

      serverProperties = {
        inherit (defaults.serverProperties)
          spawn-protection
          view-distance
          simulation-distance
          gamemode
          difficulty
          ;

        server-port = 25565;
      };

      symlinks = {
        "mods" = pkgs.linkFarmFromDrvs "mods" (
          builtins.attrValues {
            FabricApi = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/thGkUOxt/fabric-api-0.107.0%2B1.21.1.jar";
              hash = "sha256-szXsIL59eocof3/Qs/b+H/SOHXqHaSd0kyJc3fOYaWQ=";
            };
            SimpleVoiceChat = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/ojiqfkMY/voicechat-fabric-1.21.1-2.5.25.jar";
              hash = "sha256-ewV0uDDP7ubQ/OgR1GnTyNo2mtzX5tF6RXLdGOP97lc=";
            };
            VeryManyPlayers = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/wnEe9KBa/versions/mUvDaDZl/vmp-fabric-mc1.21.1-0.2.0%2Bbeta.7.169-all.jar";
              hash = "sha256-Wc6pAVv6d2DShg9GONVYNw0VE9BZmlKSU1ichsg79wk=";
            };
            Lithium = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/2mbrKlX3/lithium-fabric-0.14.0-snapshot%2Bmc1.21.1-build.88.jar";
              hash = "sha256-TzLhGkI1VeLAf+sRLUJCX1BXuqSfTytnC04FL1i5Kug=";
            };
            Chunky = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/fALzjamp/versions/dPliWter/Chunky-1.4.16.jar";
              hash = "sha256-yfA+Mi5jHulMy42/N3aFnNEnZuUTt1M+n5ZueZ20eTc=";
            };
            Bluemap = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/swbUV1cr/versions/Ysj3eVYx/bluemap-5.4-fabric.jar";
              hash = "sha256-ieaouhHgZh7+m+/6KJj5MNu3VUbDaz015sUfsSZLyic=";
            };
          }
        );
        "config/voicechat/voicechat-server.properties" = ./smp/voicechat-server.properties;

        "config/bluemap/core.conf" = ./smp/bluemap/core.conf;
        "config/bluemap/plugin.conf" = ./smp/bluemap/plugin.conf;
        "config/bluemap/webapp.conf" = ./smp/bluemap/webapp.conf;
        "config/bluemap/webserver.conf" = ./smp/bluemap/webserver.conf;
      };
    };
  };
}
