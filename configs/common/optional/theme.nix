{
  lib,
  lib',
  pkgs,
  inputs,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption;

  cfg = config.nanoflake.theme;

  catppuccin = {
    enable = !cfg.enableAutoStylix;
    flavor = "mocha";
    accent = "pink";
  };

  midnight-theme = pkgs.midnight-theme.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [ ./vencord-icon.patch ];
  });

  iconPkg = pkgs.catppuccin-papirus-folders.override {
    inherit (catppuccin) accent flavor;
  };
in

{
  options.nanoflake.theme.enableAutoStylix = mkEnableOption "stylix auto application";

  imports = [
    inputs.stylix.nixosModules.stylix
    inputs.catppuccin.nixosModules.catppuccin
  ];

  config = {
    home-manager.sharedModules = [
      inputs.catppuccin.homeManagerModules.catppuccin
    ];

    boot = {
      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "boot.shell_on_fail"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=0"
        "udev.log_priority=0"
      ];

      plymouth.enable = true;
    };

    catppuccin = {
      inherit (catppuccin) enable flavor accent;

      sddm.enable = false;
      plymouth.enable = false;
    };

    stylix = {
      enable = true;
      autoEnable = cfg.enableAutoStylix;

      cursor = {
        package = pkgs.rose-pine-cursor;
        name = "BreezeX-RosePine-Linux";
        size = 32;
      };

      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-${catppuccin.flavor}.yaml";
      polarity = "dark";

      # revert until https://github.com/NixOS/nix/pull/10153 is merged
      image = pkgs.fetchurl {
        url = "https://na55l3zepb4kcg0zryqbdnay.theless.one/valle_goodbye_declaration.png";
        hash = "sha256-NqA/Yq67T6ZBWUk73VUmPK4GJ4FUetLcZ0lfLerV+Cc=";
      };

      fonts = {
        serif = {
          name = "Noto Sans";
          package = pkgs.noto-fonts-cjk-sans;
        };

        sansSerif = {
          name = "Noto Sans";
          package = pkgs.noto-fonts-cjk-sans;
        };

        monospace = {
          name = "Cascadia Mono";
          package = pkgs.cascadia-code;
        };

        emoji = {
          name = "Twitter Color Emoji";
          package = pkgs.twemoji-color-font;
        };

        sizes = {
          applications = 10;
          terminal = 12;
          desktop = 9;
          popups = 9;
        };
      };

      targets.plymouth.enable = true;
    };

    environment.systemPackages = lib.mkIf (!cfg.enableAutoStylix) [
      iconPkg

      (pkgs.catppuccin.override {
        inherit (catppuccin) accent;
        variant = catppuccin.flavor;
      })

      (pkgs.catppuccin-kde.override {
        flavour = [ catppuccin.flavor ];
        accents = [ catppuccin.accent ];
      })
    ];

    hm =
      {
        catppuccin = {
          inherit (catppuccin) enable flavor accent;

          kvantum = {
            inherit (catppuccin) enable flavor accent;
            apply = !cfg.enableAutoStylix;
          };

          gtk.icon = catppuccin;
        };

        xdg.configFile."vesktop/themes".source = "${midnight-theme}/share/themes/flavors";
      }
      // lib.attrsets.optionalAttrs (config.nanoflake.desktop ? plasma6) {
        programs.plasma = {
          workspace = {
            lookAndFeel = "Catppuccin-${lib'.toUppercase catppuccin.flavor}-${lib'.toUppercase catppuccin.accent}";
            cursor = {
              theme = "BreezeX-RosePine-Linux";
              size = 32;
            };
            iconTheme = "Papirus-Dark";
            wallpaper = config.stylix.image;
          };

          panels = [
            {
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
                # {
                #   name = "org.kde.plasma.kickerdash";
                #   config.General = rec {
                #     icon = "nix-snowflake";
                #     limitDepth = true;
                #     recentOrdering = 1;
                #     showIconsRootLevel = true;
                #     showRecentApps = false;
                #     showRecentDocs = false;
                #     favoriteSystemActions = "logout,reboot,shutdown";
                #     systemFavorites = favoriteSystemActions;
                #     useExtraRunners = false;
                #     favoritesPortedToKAstats = true;
                #     alphaSort = true;
                #   };
                # }
                "org.kde.plasma.marginsseparator"
                {
                  iconTasks.launchers = [
                    "preferred://filemanager"
                    "preferred://browser"
                    "applications:Alacritty.desktop"
                    "applications:vesktop.desktop"
                  ] ++ lib.optionals config.programs.steam.enable [ "applications:steam.desktop" ];
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
            "kscreenlockerrc"."Greeter/Wallpaper/org.kde.image/General"."Image" = config.stylix.image;
            "kscreenlockerrc"."Greeter/Wallpaper/org.kde.image/General"."PreviewImage" = config.stylix.image;
            "plasmarc"."Wallpapers"."usersWallpapers" = config.stylix.image;
            "kcminputrc"."Mouse"."cursorSize" = 32;
          };
        };
      };
  };
}
