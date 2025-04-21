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

    whitelist = {
      Rascal1934 = "fe111f4f-6936-422c-b282-53a9a660f2b5";
      nanoyaki = "433b63b5-5f77-4a9f-b834-8463d520500c";
      Angreiferr = "885ca84d-669f-4cd7-a7a8-273d94fb7cd4";
      NoWAY5 = "9760028f-eaeb-4699-8a46-a204f5b1feac";
      einfach_calle = "3210afd0-4620-4120-9f49-d5379bf8e0b2";
      sleepyLeyla = "8f9f8556-53fb-4ed0-b1d8-aa9d5078d170";
      SleeperLuLu = "bcd341a1-8bfc-498b-a1e7-9fdd06e28860";
      StinkySoks = "d333b68f-f970-42cd-a054-90c000c00404";
      AQuuRious = "a1631188-b4b7-43a0-8828-04e63c602418";
      LiamKia = "a177db00-c53e-428b-b468-edda01775bab";
      wayne_gretzky = "435568af-9165-4b43-939d-a3f731742d43";
      PhillipTheLord1 = "9a030337-eb2b-4acc-9fef-ec941dd6454c";
    };
  };

  inherit (pkgs) fetchurl;
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
            FabricApi = fetchurl {
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/bQZpGIz0/fabric-api-0.119.2%2B1.21.4.jar";
              sha512 = "bb8de90d5d1165ecc17a620ec24ce6946f578e1d834ddc49f85c2816a0c3ba954ec37e64f625a2f496d35ac1db85b495f978a402a62bbfcc561795de3098b5c9";
            };
            SimpleVoiceChat = fetchurl {
              url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/pl9FpaYJ/voicechat-fabric-1.21.4-2.5.26.jar";
              sha512 = "c262302256a708d5ecb3e2d61de74bfb600b8892a5ef2780a309fff296f4e0123f6b95e10fd9823b5b2e4c532d0f013d94c87be0ddaba3423a5296ba1a7ed119";
            };
            VeryManyPlayers = fetchurl {
              url = "https://cdn.modrinth.com/data/wnEe9KBa/versions/61Gy0NAD/vmp-fabric-mc1.21.4-0.2.0%2Bbeta.7.192-all.jar";
              sha512 = "4e13cfbb97099784bb27fbb87eebc163974ba6c31081829d01ae435920d2604df03c625d5daecbefa1a0cca40b699840d5e964819993b451b1c9c7a7bd7c80d2";
            };
            Lithium = fetchurl {
              url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/969795RH/lithium-fabric-0.15.1%2Bmc1.21.4.jar";
              sha512 = "f3dfb0810b2ddf1b430fc206be7c40453310b91efe9c82ab88d998e8707dd081e5e9cbbd44df125a2d43a418466216e5df87e34389f54b4aae9caf19df4382c9";
            };
            Chunky = fetchurl {
              url = "https://cdn.modrinth.com/data/fALzjamp/versions/VkAgASL1/Chunky-Fabric-1.4.27.jar";
              sha512 = "a89f94947e7c3992e01e46be8967d2a6593334333a546b4fff5fdb02a1f5a6b83c93adc4c72a9b9b1f14f9299efcaa8a5d7f5eeedf3da541c7e72abc5e2724c6";
            };
            Bluemap = fetchurl {
              url = "https://cdn.modrinth.com/data/swbUV1cr/versions/Dr2hvJBc/bluemap-5.7-fabric.jar";
              sha512 = "b7483d6ff90f09258f994a6f487846c1dfe814f1d0af931bd50426fd0afc98ccad033c5f440705edc08a8ced03cf216171ba1571db2221aca4ec620d676443a4";
            };
            DistantHorizons = fetchurl {
              url = "https://cdn.modrinth.com/data/uCdwusMi/versions/DTFSZmMF/DistantHorizons-neoforge-fabric-2.3.0-b-1.21.4.jar";
              sha512 = "7337d486cde3dd43f5bed5f81277170d0dab4257f5d355e1dc88d5cfb5577a8592a35a3df80d35e1ec81b799ebc7b398c348cec6e73a0d37e7952883e49d06dd";
            };
            PlayerRoles = fetchurl {
              url = "https://cdn.modrinth.com/data/Rt1mrUHm/versions/Y5EAJzwR/player-roles-1.6.13.jar";
              sha512 = "14cf8bb7da02fdb61765dd12b8f9fb0c92b5dfdce7d2b4068eb64735ddd97707e237d7845c4868acdabe2eb6b844f3d5cb525399571aa1eb007b4d521e5ffd15";
            };
            BluemapSignMarkers = fetchurl {
              url = "https://cdn.modrinth.com/data/i5ZtmNIW/versions/cC2uWgOu/bluemapsignmarkers-1.21.4-0.7.1.40.jar";
              sha512 = "6fe867732bd4d12dbfe1f74c696973a8ae780df8b671548e42f53c04ed82ffb8e9164c5ba884e36af79bce9a9e849964b6d8c1f1753063d8f92bd7e8e7456c6c";
            };
            NoChatReports = fetchurl {
              url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/9xt05630/NoChatReports-FABRIC-1.21.4-v2.11.0.jar";
              sha512 = "d343b05c8e50f1de15791ff622ad44eeca6cdcb21e960a267a17d71506c61ca79b1c824167779e44d778ca18dcbdebe594ff234fbe355b68d25cdb5b6afd6e4f";
            };
            Noisium = fetchurl {
              url = "https://cdn.modrinth.com/data/KuNKN7d2/versions/9NHdQfkN/noisium-fabric-2.5.0%2Bmc1.21.4.jar";
              sha512 = "3119f9325a9ce13d851d4f6eddabade382222c80296266506a155f8e12f32a195a00a75c40a8d062e4439f5a7ef66f3af9a46f9f3b3cb799f3b66b73ca2edee8";
            };
            Krypton = fetchurl {
              url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/Acz3ttTp/krypton-0.2.8.jar";
              sha512 = "5f8cf96c79bfd4d893f1d70da582e62026bed36af49a7fa7b1e00fb6efb28d9ad6a1eec147020496b4fe38693d33fe6bfcd1eebbd93475612ee44290c2483784";
            };
            C2MEngine = fetchurl {
              url = "https://cdn.modrinth.com/data/VSNURh3q/versions/EzvMx6b2/c2me-fabric-mc1.21.4-0.3.1.3.0.jar";
              sha512 = "f944bf4319cfa6fb645d0cbe807b82c74784f44ef7ac75273efa161be4625aa80390ec8cf32a232c0ebce0d0cb23b090979019d93e7550771de56d09d920dd13";
            };
            Image2Map = fetchurl {
              url = "https://cdn.modrinth.com/data/13RpG7dA/versions/kkdbWskW/image2map-0.8.0%2B1.21.3.jar";
              sha512 = "fab2fcca41a8d5e39ef48bfd557c4bfb4d27383d7bc9415c76b2100f52e34ae3bb6a5f9919a6617c2a081a886b9f869ff2c626a376e7b54a9f5491d14a66b54c";
            };
          }
        );
        "config/voicechat/voicechat-server.properties" = ./smp/voicechat-server.properties;

        "config/bluemap/core.conf" = ./smp/bluemap/core.conf;
        "config/bluemap/plugin.conf" = ./smp/bluemap/plugin.conf;
        "config/bluemap/webapp.conf" = ./smp/bluemap/webapp.conf;
        "config/bluemap/webserver.conf" = ./smp/bluemap/webserver.conf;

        "config/roles.json" = (pkgs.formats.json { }).generate "roles.json" {
          whitelister.overrides.commands."whitelist (add|remove)" = "allow";
        };
      };
    };
  };

  sec."restic/smp" = { };

  services.restic.backups.smp = {
    initialize = true;
    repository = "/var/lib/restic/backups/smp";
    passwordFile = config.sec."restic/smp".path;

    paths = [
      "${config.services.minecraft-servers.dataDir}/smp/world"
    ];
    exclude = [
      "${config.services.minecraft-servers.dataDir}/smp/world/**/data/DistantHorizons*"
    ];

    environmentFile = ''${pkgs.writeText "restic-smp-env" ''
      GOMAXPROCS=6
    ''}'';

    timerConfig = {
      OnCalendar = "*:0/30";
      Persistent = true;
      RandomizedDelaySec = "30s";
    };

    backupPrepareCommand = lib.getExe (
      pkgs.writeShellApplication {
        name = "backupPrepareCommandSmp";
        runtimeInputs = with pkgs; [
          coreutils-full
          tmux
        ];
        text = ''
          systemctl is-active minecraft-server-smp.service --quiet && \
          date +%s > /tmp/minecraftServerSmpBackupStartTime
          tmux -S /run/minecraft/smp.sock send-keys \
            'tellraw @a ["",{"text":"['"$(date -d "@$(cat /tmp/minecraftServerSmpBackupStartTime)" +"%d.%m.%Y %H:%M")"'] ","color":"white"},{"text":"Backup gestartet","color":"dark_red","clickEvent":{"action":"open_url","value":"https://tinyurl.com/n7rn4dbh"},"hoverEvent":{"action":"show_text","contents":[{"text":"Free V-Bucks","color":"aqua"}]}}]' \
            Enter
        '';
      }
    );
    backupCleanupCommand = lib.getExe (
      pkgs.writeShellApplication {
        name = "backupCleanupCommandSmp";
        runtimeInputs = with pkgs; [
          coreutils-full
          tmux
        ];
        text = ''
          systemctl is-active minecraft-server-smp.service --quiet && \
          tmux -S /run/minecraft/smp.sock send-keys \
            'tellraw @a ["",{"text":"['"$(date +"%d.%m.%Y %H:%M")"'] ","color":"white"},{"text":"Backup vollendet","bold":true,"color":"green","hoverEvent":{"action":"show_text","contents":[{"text":"'"$(date -d "@$(( "$(date +%s)" - "$(cat /tmp/minecraftServerSmpBackupStartTime)" ))" +"%M:%S")"'m gebraucht. Das Backup verbraucht nun '"$(du -bsh /var/lib/restic/backups/smp | cut -f1)"'","color":"green"}]}}]' \
            Enter
        '';
      }
    );

    pruneOpts = [
      "--keep-last 3"
      "--keep-hourly 24"
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 6"
      "--keep-yearly 2"
    ];
  };

  systemd.tmpfiles.settings."10-restic-backups"."/var/lib/restic/backups".d = {
    mode = "0700";
    user = "root";
    group = "wheel";
  };
}
