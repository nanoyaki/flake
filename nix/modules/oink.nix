{
  flake.nixosModules.oink =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    let
      inherit (lib) mkOption types;

      cfg = config.self.oink;
    in

    {
      options.self.oink.configFile = mkOption {
        type = types.externalPath;
      };

      config.systemd.services.oink = {
        description = "Dynamic DNS client for Porkbun";
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          LoadCredential = "oink.json:${cfg.configFile}";
          ExecStart = "${lib.getExe pkgs.oink} -c \${CREDENTIALS_DIRECTORY}/oink.json -v";
          Restart = "always";
          Type = "simple";

          # Hardening
          DynamicUser = true;
          CapabilityBoundingSet = "";
          SystemCallFilter = [ "@system-service" ];

          NoNewPrivileges = true;
          ProtectClock = true;
          RestrictNamespaces = true;
          RestrictSUIDSGID = true;
          LockPersonality = true;
          RestrictRealtime = true;
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];
          MemoryDenyWriteExecute = true;
          ProtectHostname = true;

          ProtectSystem = "strict";
          PrivateTmp = true;
          ProtectHome = true;
          PrivateDevices = true;
          ProtectControlGroups = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectKernelLogs = true;
          ProtectProc = "invisible";
        };
      };
    };
}
