{
  lib,
  lib',
  pkgs,
  inputs,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkPackageOption;

  cfg = config.nanoflake.theme;

  catppuccin = {
    enable = !cfg.enableAutoStylix;
    flavor = "mocha";
    accent = "pink";
  };

  midnight-theme = pkgs.midnight-theme.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [ ./vencord-icon.patch ];
  });
in

{
  options.nanoflake.theme = {
    enableAutoStylix = mkEnableOption "stylix auto application";

    iconPackage = (mkPackageOption pkgs "catppuccin-papirus-folders" { }) // {
      default = pkgs.catppuccin-papirus-folders.override { inherit (catppuccin) accent flavor; };
    };
  };

  imports = [
    inputs.stylix.nixosModules.stylix
    inputs.catppuccin.nixosModules.catppuccin
  ];

  config = {
    home-manager.sharedModules = [
      inputs.catppuccin.homeModules.catppuccin
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
        url = "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:majihettvb7ieflgmkvujecu/bafkreifj2it2zsr4x5iiv7ti5hcf7l3bwoym6fn2xn7mygohsm4sptcgbu";
        hash = "sha256-uuoCCTDvuzowPdQAjFno2XZMLWtJIPXX/i/Ko0AONaY=";
      };

      fonts = {
        serif = {
          name = "Noto Sans CJK JP";
          package = pkgs.noto-fonts-cjk-sans;
        };

        sansSerif = {
          name = "Noto Sans CJK JP";
          package = pkgs.noto-fonts-cjk-sans;
        };

        monospace = {
          name = "CaskaydiaCove Nerd Font Mono";
          package = pkgs.nerd-fonts.caskaydia-cove;
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
      cfg.iconPackage

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
          swaync.enable = true;
          waybar.enable = true;
          sway.enable = true;

          rofi.enable = false;
        };

        gtk = rec {
          enable = true;

          font = {
            package = pkgs.noto-fonts-cjk-sans;
            name = "Noto Sans";
          };

          gtk2.configLocation = "${config.hm.xdg.configHome}/gtk-2.0/gtkrc";
          gtk2.extraConfig = ''
            gtk-application-prefer-dark-theme="true"
          '';

          gtk3.extraConfig = {
            gtk-application-prefer-dark-theme = true;
            gtk-menu-images = true;
            gtk-primary-button-warps-slider = true;
            gtk-toolbar-style = 3;
            gtk-decoration-layout = ":minimize,maximize,close";
            # gtk-enable-animations = false;
          };

          gtk4 = { inherit (gtk3) extraConfig; };
        };

        programs.rofi.theme = "${pkgs.rofi-themes}/share/themes/launchers/type-2/style-1.rasi";
        wayland.windowManager.sway.config.output = {
          "HDMI-A-1".bg = "${config.stylix.image} fill";
          "DP-1".bg = "${config.stylix.image} fill";
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
            enableMiddleClickPaste = false;
          };

          panels = [
            {
              screen = 0;
              location = "bottom";
              widgets =
                [
                  # https://develop.kde.org/docs/plasma/scripting/keys/
                  {
                    panelSpacer.expanding = true;
                  }
                ]
                ++ lib.optional (!config.hm.programs.rofi.enable) {
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
                ++ [
                  "org.kde.plasma.marginsseparator"
                  {
                    iconTasks.launchers = [
                      "preferred://filemanager"
                      "preferred://browser"
                      "applications:Alacritty.desktop"
                      "applications:vesktop.desktop"
                    ] ++ lib.optional config.programs.steam.enable "applications:steam.desktop";
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
