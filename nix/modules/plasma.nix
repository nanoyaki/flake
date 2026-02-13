{ inputs, ... }:

{
  flake.nixosModules.plasma =
    { pkgs, ... }:

    {
      services.desktopManager.plasma6 = {
        enable = true;
        enableQt5Integration = false;
      };

      services.displayManager.defaultSession = "plasma";
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        wayland.compositor = "kwin";
      };

      environment.plasma6.excludePackages = with pkgs.kdePackages; [
        konsole
        kate
        ktexteditor
        baloo-widgets
        okular
        elisa
        khelpcenter
        discover
      ];

      xdg.mime.defaultApplications = {
        "inode/directory" = "org.kde.dolphin.desktop";
      };
    };

  flake.homeModules.plasma =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    {
      imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

      programs.plasma = {
        workspace = {
          iconTheme = "Papirus-Dark";
          wallpaper = pkgs.default-wallpaper.outPath;
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
                  "preferred://mailer"
                  "preferred://browser"
                  "preferred://terminal"
                  # "applications:Alacritty.desktop"
                  "applications:vesktop.desktop"
                  "applications:codium.desktop"
                ]
                ++ lib.optional config.programs.steam.enable "applications:steam.desktop";
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
              # "org.kde.plasma.showdesktop"
            ];
          }
        ];

        configFile = {
          kscreenlockerrc."Greeter/Wallpaper/org.kde.image/General".Image = pkgs.default-wallpaper.outPath;
          kscreenlockerrc."Greeter/Wallpaper/org.kde.image/General".PreviewImage =
            pkgs.default-wallpaper.outPath;
          plasmarc.Wallpapers.usersWallpapers = pkgs.default-wallpaper.outPath;
          kcminputrc.Mouse.cursorSize = 32;

          kdeglobals.General.TerminalApplication = "alacritty";
          emaildefaults.Defaults.Profile = "Default";
          emaildefaults.PROFILE_Default = {
            EmailClient = "thunderbird.desktop";
            TerminalClient = false;
          };
        };
      };
    };
}
