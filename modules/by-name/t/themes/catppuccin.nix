{
  lib,
  lib',
  inputs,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) mkIf optional;
  inherit (lib'.options) mkDefault mkStrOption mkFalseOption;
  inherit (builtins) removeAttrs;
  inherit (inputs) stylix catppuccin;

  cfg = config.config'.theming.catppuccin;
  inherit (config.config'.theming.stylix) enableAutoStylix;
in

{
  imports = [
    stylix.nixosModules.stylix
    catppuccin.nixosModules.catppuccin
  ];

  options.config'.theming.catppuccin = {
    enable = mkFalseOption;

    flavor = mkDefault "mocha" mkStrOption;
    accent = mkDefault "pink" mkStrOption;
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (_: prev: {
        midnight-theme = prev.midnight-theme.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or [ ]) ++ [ ./vencord-icon.patch ];
        });
      })
    ];

    environment.systemPackages = mkIf (!enableAutoStylix) [
      (pkgs.catppuccin-papirus-folders.override (removeAttrs cfg [ "enable" ]))

      (pkgs.catppuccin.override {
        inherit (cfg) accent;
        variant = cfg.flavor;
      })

      (pkgs.catppuccin-kde.override {
        flavour = [ cfg.flavor ];
        accents = [ cfg.accent ];
      })
    ];

    hms = [
      {
        imports = [ catppuccin.homeModules.catppuccin ];

        catppuccin = {
          enable = true;
          inherit (cfg) flavor accent;

          kvantum = {
            enable = true;
            inherit (cfg) flavor accent;
            apply = !enableAutoStylix;
          };

          gtk.icon = cfg;
          swaync.enable = true;
          waybar.enable = true;
          sway.enable = true;

          rofi.enable = false;
        };

        xdg.configFile."vesktop/themes".source = "${pkgs.midnight-theme}/share/themes/flavors";

        programs.plasma = {
          workspace = {
            lookAndFeel = "Catppuccin-${lib'.toUppercase cfg.flavor}-${lib'.toUppercase cfg.accent}";
            cursor = {
              theme = "BreezeX-RosePine-Linux";
              size = 32;
            };
            iconTheme = "Papirus-Dark";
            wallpaper = config.stylix.image;
            enableMiddleClickPaste = false;
          };

          panels = [
            {
              screen = 0;
              location = "bottom";
              widgets = [
                # https://develop.kde.org/docs/plasma/scripting/keys/
                {
                  panelSpacer.expanding = true;
                }
                {
                  kickoff = {
                    icon = "nix-snowflake";
                    label = null;
                    sortAlphabetically = true;
                    sidebarPosition = "left";
                    favoritesDisplayMode = "grid";
                    applicationsDisplayMode = "grid";
                    showButtonsFor = "powerAndSession";
                    showActionButtonCaptions = false;
                    pin = false;
                  };
                }
                "org.kde.plasma.marginsseparator"
                {
                  iconTasks.launchers = [
                    "preferred://filemanager"
                    "preferred://browser"
                    "applications:Alacritty.desktop"
                    "applications:vesktop.desktop"
                  ]
                  ++ optional config.programs.steam.enable "applications:steam.desktop";
                }
                {
                  panelSpacer.expanding = true;
                }
                {
                  systemTray.items = {
                    shown = [
                      "org.kde.plasma.volume"
                      "plasmashell_microphone"
                      "org.kde.plasma.networkmanagement"
                      "org.kde.plasma.battery"
                    ];

                    hidden = [
                      "org.kde.plasma.clipboard"
                      "org.kde.plasma.keyboardindicator"
                      "org.kde.plasma.keyboardlayout"
                      "org.kde.kscreen"
                      "org.kde.plasma.brightness"
                      "org.kde.plasma.mediacontroller"
                      "Fcitx"
                    ];
                  };
                }
                {
                  digitalClock = {
                    calendar = {
                      firstDayOfWeek = "monday";
                      showWeekNumbers = true;
                    };
                    date = {
                      format.custom = "dd.MM.yy";
                      position = "belowTime";
                    };
                    time = {
                      showSeconds = "onlyInTooltip";
                      format = "24h";
                    };
                    timeZone = {
                      format = "code";
                      selected = [ "Europe/Berlin" ];
                    };
                  };
                }
                "org.kde.plasma.showdesktop"
              ];
            }
          ];

          configFile = {
            "kscreenlockerrc"."Greeter/Wallpaper/org.kde.image/General".Image = "${config.stylix.image}";
            "kscreenlockerrc"."Greeter/Wallpaper/org.kde.image/General".PreviewImage = "${config.stylix.image}";
            "plasmarc"."Wallpapers"."usersWallpapers" = "${config.stylix.image}";
            "kcminputrc"."Mouse"."cursorSize" = 32;
          };
        };
      }
    ];
  };
}
