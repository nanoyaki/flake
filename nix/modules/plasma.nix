{ inputs, ... }:

{
  flake.nixosModules.plasma =
    { pkgs, ... }:

    {
      programs.partition-manager.enable = true;

      services.desktopManager.plasma6 = {
        enable = true;
        enableQt5Integration = false;
      };

      services.displayManager.defaultSession = "plasma";
      services.displayManager.plasma-login-manager.enable = true;

      programs.kclock.enable = true;

      # Ark rar and 7z compatibility
      environment.systemPackages = with pkgs; [
        p7zip
        unrar
      ];
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
    args@{
      lib,
      pkgs,
      ...
    }:

    {
      imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

      programs.plasma = {
        enable = true;

        shortcuts = {
          "services/com.tomjwatson.Emote.desktop"._launch = "Meta+.";
          "services/Alacritty.desktop"._launch = "Meta+T";
          "kwin/Edit Tiles".value = "none";
        };

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
                plasmusicToolbar = {
                  panelIcon.albumCover = {
                    fallbackToIcon = true;
                    useAsIcon = true;
                    radius = 25;
                  };

                  playbackSource = "auto";
                };
              }
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
                  # "preferred://terminal"
                  "applications:Alacritty.desktop"
                  # "applications:discord.desktop"
                  "applications:vesktop.desktop"
                  "applications:codium.desktop"
                ]
                ++ lib.optional (
                  args ? nixosConfig && args.nixosConfig.programs.steam.enable
                ) "applications:steam.desktop";
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

          kdeglobals.General.TerminalApplication = "alacritty.desktop";
          emaildefaults.Defaults.Profile = "Default";
          emaildefaults.PROFILE_Default = {
            EmailClient = "thunderbird.desktop";
            TerminalClient = false;
          };
        };
      };
    };
}
