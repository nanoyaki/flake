{ withSystem, ... }:

{
  flake.nixosModules.shirayuri-vr =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    {
      # Make sure to `sudo renice -20 -p $(pgrep monado)`
      services.monado = {
        enable = true;
        defaultRuntime = true;
        highPriority = true;
        package = pkgs.monado;
      };

      systemd.user.services.monado.environment = {
        STEAMVR_PATH = "${config.self.mainUserHome}/.local/share/Steam/steamapps/common/SteamVR";
        XR_RUNTIME_JSON = "${config.self.mainUserHome}/.config/openxr/1/active_runtime.json";
        STEAMVR_LH_ENABLE = "1";
        XRT_COMPOSITOR_COMPUTE = "1";
        WMR_HANDTRACKING = "1";
        # LH_HANDTRACKING = "on";
      };

      systemd.user.services.wayvr = {
        description = "WayVR background service";
        wantedBy = [ "monado.service" ];
        after = [ "monado.service" ];
        bindsTo = [ "monado.service" ];
        partOf = [ "monado.service" ];

        unitConfig.ConditionUser = "!root";

        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.wayvr} --openxr";
          Restart = "on-failure";
          Type = "simple";
        };

        environment = {
          XR_RUNTIME_JSON = "${config.self.mainUserHome}/.config/openxr/1/active_runtime.json";
          LIBMONADO_PATH = "${config.services.monado.package}/lib/libmonado.so";
        };

        restartTriggers = [ pkgs.wayvr ];
      };

      environment.systemPackages = [ pkgs.wayvr ];
    };

  flake.homeModules.hana-vr =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    {
      xdg.configFile."openvr/openvrpaths.vrpath".text = builtins.toJSON {
        version = 1;
        jsonid = "vrpathreg";
        external_drivers = null;
        config = [ "${config.xdg.dataHome}/Steam/config" ];
        log = [ "${config.xdg.dataHome}/Steam/logs" ];
        runtime = [
          "${pkgs.xrizer}/lib/xrizer"
          "${pkgs.opencomposite-vendored}/lib/opencomposite"
          "${config.xdg.dataHome}/Steam/steamapps/common/SteamVR"
        ];
      };

      xdg.configFile."openxr/1/active_runtime.json".source =
        "${pkgs.monado}/share/openxr/1/openxr_monado.json";

      xdg.dataFile."monado/hand-tracking-models".source = pkgs.fetchgit {
        url = "https://gitlab.freedesktop.org/monado/utilities/hand-tracking-models.git";
        fetchLFS = true;
        hash = "sha256-x/X4HyyHdQUxn3CdMbWj5cfLvV7UyQe1D01H93UCk+M=";
      };

      xdg.desktopEntries.monado = {
        name = "Monado";
        comment = "Starts the Monado OpenXR service";
        exec = lib.getExe (
          pkgs.writeSystemdToggle.override {
            service = "monado";
            isUserService = true;
          }
        );
        icon = "${pkgs.catppuccin-papirus-folders}/share/icons/Papirus/64x64/apps/steamvr.svg";
        categories = [
          "Game"
          "Graphics"
          "3DGraphics"
        ];
        terminal = false;
      };
    };

  perSystem =
    { pkgs, ... }:

    {
      packages.xrizer = pkgs.xrizer.overrideAttrs { patches = [ ]; };
    };

  flake.overlays.vr =
    _: prev:

    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }:

      {
        inherit (config.packages) xrizer;
      }
    );
}
