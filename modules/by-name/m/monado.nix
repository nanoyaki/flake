{
  lib,
  lib',
  pkgs,
  config,
  ...
}:

# https://wiki.nixos.org/wiki/VR#Monado
{
  options.config'.monado.enable = lib'.options.mkFalseOption;

  config = lib.mkIf config.config'.monado.enable {
    nixpkgs.overlays = [
      (_: prev: {
        monado = prev.monado.overrideAttrs (oldAttrs: {
          buildInputs = builtins.filter (x: x != prev.opencv) oldAttrs.buildInputs;
          cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
            "-DBUILD_WITH_OPENCV=OFF"
          ];
        });
      })
    ];

    hm.xdg.configFile."openvr/openvrpaths.vrpath".text = ''
      {
        "config" :
        [
          "${config.hm.xdg.dataHome}/Steam/config"
        ],
        "external_drivers" : null,
        "jsonid" : "vrpathreg",
        "log" :
        [
          "${config.hm.xdg.dataHome}/Steam/logs"
        ],
        "runtime" :
        [
          "${pkgs.opencomposite-vendored}/lib/opencomposite",
          "${pkgs.xrizer}/lib/xrizer",
          "${config.hm.xdg.dataHome}/Steam/steamapps/common/SteamVR"
        ],
        "version" : 1
      }
    '';

    hm.xdg.configFile."openxr/1/active_runtime.json".source =
      "${pkgs.monado}/share/openxr/1/openxr_monado.json";

    hm.xdg.dataFile."monado/hand-tracking-models".source = pkgs.fetchgit {
      url = "https://gitlab.freedesktop.org/monado/utilities/hand-tracking-models.git";
      fetchLFS = true;
      hash = "sha256-x/X4HyyHdQUxn3CdMbWj5cfLvV7UyQe1D01H93UCk+M=";
    };

    # Make sure to `sudo renice -20 -p $(pgrep monado)`
    services.monado = {
      enable = true;
      defaultRuntime = true;
      highPriority = true;
      package = pkgs.monado;
    };

    systemd.user.services.monado.environment = {
      STEAMVR_PATH = "${config.hm.xdg.dataHome}/Steam/steamapps/common/SteamVR";
      XR_RUNTIME_JSON = "${config.hm.xdg.configHome}/openxr/1/active_runtime.json";
      STEAMVR_LH_ENABLE = "1";
      XRT_COMPOSITOR_COMPUTE = "1";
      WMR_HANDTRACKING = "1";
      # LH_HANDTRACKING = "on";
    };

    hm.xdg.desktopEntries.monado = {
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
}
