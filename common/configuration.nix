# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  lib,
  username,
  ...
}: {
  # Boot settings
  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = lib.mkDefault true;
        efiSysMountPoint = "/boot/efi";
      };
      grub = {
        catppuccin.enable = true;
        catppuccin.flavor = "frappe";
        configurationLimit = 35;
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
      };
    };
    supportedFilesystems = ["ntfs"];
    kernelPackages = pkgs.linuxKernel.packages.linux_lqx;
  };
  time.hardwareClockInLocalTime = true;

  # Nix settings
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  i18n.supportedLocales = [
    "en_GB.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "de_DE.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
    "C.UTF-8/UTF-8"
  ];

  # Keyboard input
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  # Configure console keymap
  console.keyMap = "de";

  fonts = {
    packages = with pkgs; [
      mplus-outline-fonts.githubRelease
    ];

    fontconfig.defaultFonts = {
      serif = ["M PLUS 2"];
      sansSerif = ["M PLUS 2"];
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  # Gnome:
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
      gedit
    ])
    ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gnome-terminal
      epiphany # web browser
      geary # email reader
      evince # document viewer
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      seahorse # password something
    ]);
  services.xserver.desktopManager.xterm.enable = false;
  services.gnome.games.enable = false;
  services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];

  # Plasma 6
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
    kate
    elisa
    kwrited
    kwallet
    ark
    okular
    print-manager
    dolphin
  ];
  programs.kdeconnect.enable = false;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Theming
  catppuccin.accent = "pink";
  catppuccin.enable = true;
  catppuccin.flavor = "frappe";

  console.catppuccin.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
    # wireplumber.enable = true;

    extraConfig = {
      pipewire."92-low-latency" = {
        context.properties = {
          default.clock.rate = 48000;
          default.clock.quantum = 32;
          default.clock.min-quantum = 32;
          default.clock.max-quantum = 32;
        };
      };

      pipewire-pulse."92-low-latency" = {
        context.modules = [
          {
            name = "libpipewire-module-protocol-pulse";
            args = {
              pulse.min.req = "32/48000";
              pulse.default.req = "32/48000";
              pulse.max.req = "32/48000";
              pulse.min.quantum = "32/48000";
              pulse.max.quantum = "32/48000";
            };
          }
        ];

        stream.properties = {
          node.latency = "32/48000";
          resample.quality = 1;
        };
      };
    };
  };

  # I HAVE NO FUCKING IDEA HOW TO MAKE OSU LAZER USE A 48K SAMPLE RATE

  # User
  users.users.${username} = {
    isNormalUser = true;
    description = "Hana";
    extraGroups = ["networkmanager" "wheel" "input" "audio"];
  };

  security.sudo.extraRules = [
    {
      users = ["${username}"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  # Enable automatic login for the user.
  services.displayManager.autoLogin = {
    enable = true;
    user = "${username}";
  };
  # Workaround for Gnome:
  systemd.services."getty@tty1".enable = lib.mkIf config.services.xserver.desktopManager.gnome.enable false;
  systemd.services."autovt@tty1".enable = lib.mkIf config.services.xserver.desktopManager.gnome.enable false;

  # Install firefox.
  programs.firefox.enable = true;

  # Zshell
  users.defaultUserShell = pkgs.zsh;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # https://search.nixos.org/packages?channel=unstable
  # TODO: make this modular
  # Environment
  environment = {
    systemPackages =
      (with pkgs; [
        # Programming
        gh
        alejandra
        rustup
        gcc
        pkg-config
        # PHP
        (pkgs.php83.buildEnv {
          extensions = {
            enabled,
            all,
          }:
            enabled ++ (with all; [mongodb redis]);
        })
        php83Packages.phpstan
        php83Packages.composer
        symfony-cli
        nodejs_22

        # Terminal
        kitty

        # Editors
        vscode

        # Files
        gnome.nautilus
        gnome.file-roller
        unrar
        unzip
        p7zip

        # Hardware
        glxinfo
        lm_sensors
        gnome.gnome-disk-utility
        baobab
        # When pipewire.service.jack.enable is true, enable this:
        # pipewire.jack

        # OS
        gnomeExtensions.appindicator
        gnomeExtensions.zen
        gnomeExtensions.window-is-ready-remover
        libsForQt5.qt5.qttools
      ])
      ++ [
        (import ./rebuild.nix {inherit pkgs;})
        (import ./nix-up.nix {inherit pkgs;})
      ];

    sessionVariables = {
      PIPEWIRE_LATENCY = "512/48000";
      FLAKE_DIR = "$HOME/flake";
      LANGUAGE = "en_GB";
      XRT_COMPOSITOR_COMPUTE = 1;
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };

    variables = {
      EDITOR = "code";
      LANGUAGE = "en_GB";
    };

    pathsToLink = ["/share/zsh"];
  };

  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme\; bindkey \"\;5C\" forward-word\; bindkey \"\;5D\" backward-word";

    shellAliases = {
      ll = "LANG=de_DE.UTF-8 ls -latr --color=auto";
      copy = "rsync -a --info=progress2 --info=name0";
      nix-conf = "code $FLAKE_DIR";
      nix-op = "firefox \"https://search.nixos.org/options?channel=unstable\"";
      nix-pac = "firefox \"https://search.nixos.org/packages?channel=unstable\"";
      nix-hom = "firefox \"https://home-manager-options.extranix.com/\"";
      nya = "cat";
      yt = "firefox youtube.com";
      x = "LANG=ja_JP.UTF-8 7z x";
    };
    histSize = 10000;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  # vcs
  programs.git.enable = true;

  # Security
  security.polkit = {
    enable = true;
    # Corectrl
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((action.id == "org.corectrl.helper.init" ||
          action.id == "org.corectrl.helperkiller.init") &&
          subject.local == true &&
          subject.active == true &&
          subject.isInGroup("wheel")) {
            return polkit.Result.YES;
          }
      });
    '';
  };

  # General hardware control
  programs.corectrl = {
    enable = true;
    gpuOverclock.enable = true;
    gpuOverclock.ppfeaturemask = "0xffffffff";
  };

  # Nautilus Settings
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

  # Gaming
  # Steam config taken from:
  # https://codeberg.org/Scrumplex/flake/src/commit/38473f45c933e3ca98f84d2043692bb062807492/nixosConfigurations/common/desktop/gaming.nix#L20-L35
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;

    extraCompatPackages = with pkgs; [
      proton-ge-bin
      (proton-ge-bin.overrideAttrs (finalAttrs: _: {
        version = "GE-Proton9-4-rtsp7";
        src = pkgs.fetchzip {
          url = "https://github.com/SpookySkeletons/proton-ge-rtsp/releases/download/${finalAttrs.version}/${finalAttrs.version}.tar.gz";
          hash = "sha256-l/zt/Kv6g1ZrAzcxDNENByHfUp/fce3jOHVAORc5oy0=";
        };
      }))
    ];
  };

  programs.gamemode = {
    enable = true;
    settings = {
      custom = {
        start = "qdbus org.kde.KWin /Compositor suspend";
        stop = "qdbus org.kde.KWin /Compositor resume";
      };
    };
  };

  services.libinput.mouse.accelProfile = "flat";

  # mullvad
  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.package = pkgs.mullvad-vpn;
}
