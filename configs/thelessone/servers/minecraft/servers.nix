{
  lib,
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

    servers.smp = lib.recursiveUpdate defaults {
      enable = true;
      package = pkgs.fabricServers.fabric-1_21_4;

      serverProperties.server-port = 25565;

      symlinks = {
        "mods" = pkgs.linkFarmFromDrvs "mods" (
          builtins.attrValues {
            FabricApi = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/bQZpGIz0/fabric-api-0.119.2%2B1.21.4.jar";
              sha512 = "bb8de90d5d1165ecc17a620ec24ce6946f578e1d834ddc49f85c2816a0c3ba954ec37e64f625a2f496d35ac1db85b495f978a402a62bbfcc561795de3098b5c9";
            };
            SimpleVoiceChat = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/pl9FpaYJ/voicechat-fabric-1.21.4-2.5.26.jar";
              sha512 = "c262302256a708d5ecb3e2d61de74bfb600b8892a5ef2780a309fff296f4e0123f6b95e10fd9823b5b2e4c532d0f013d94c87be0ddaba3423a5296ba1a7ed119";
            };
            VeryManyPlayers = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/wnEe9KBa/versions/61Gy0NAD/vmp-fabric-mc1.21.4-0.2.0%2Bbeta.7.192-all.jar";
              sha512 = "4e13cfbb97099784bb27fbb87eebc163974ba6c31081829d01ae435920d2604df03c625d5daecbefa1a0cca40b699840d5e964819993b451b1c9c7a7bd7c80d2";
            };
            Lithium = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/969795RH/lithium-fabric-0.15.1%2Bmc1.21.4.jar";
              sha512 = "f3dfb0810b2ddf1b430fc206be7c40453310b91efe9c82ab88d998e8707dd081e5e9cbbd44df125a2d43a418466216e5df87e34389f54b4aae9caf19df4382c9";
            };
            Chunky = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/fALzjamp/versions/VkAgASL1/Chunky-Fabric-1.4.27.jar";
              sha512 = "a89f94947e7c3992e01e46be8967d2a6593334333a546b4fff5fdb02a1f5a6b83c93adc4c72a9b9b1f14f9299efcaa8a5d7f5eeedf3da541c7e72abc5e2724c6";
            };
            Bluemap = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/swbUV1cr/versions/Dr2hvJBc/bluemap-5.7-fabric.jar";
              sha512 = "b7483d6ff90f09258f994a6f487846c1dfe814f1d0af931bd50426fd0afc98ccad033c5f440705edc08a8ced03cf216171ba1571db2221aca4ec620d676443a4";
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
