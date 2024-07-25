# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  lib,
  username,
  settings,
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
        catppuccin.flavor = "macchiato";
        configurationLimit = 35;
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
      };
    };
    supportedFilesystems = ["ntfs"];
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
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
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  # Configure console keymap
  console.keyMap = "de";

  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      mplus-outline-fonts.githubRelease
    ];

    fontconfig = {
      antialias = true;
      defaultFonts = {
        serif = ["M PLUS 2"];
        sansSerif = ["M PLUS 2"];
      };
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.displayManager.defaultSession = "plasmax11";

  # Plasma 6
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
    kate
    elisa
    kwrited
    ark
    okular
    print-manager
  ];
  programs.kdeconnect.enable = false;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Theming
  catppuccin.enable = true;
  catppuccin.accent = "pink";
  catppuccin.flavor = "macchiato";

  console.catppuccin.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
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
  };

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

  # Install browsers.
  programs.firefox.enable = true;
  programs.chromium = {
    enable = true;

    extraOpts = {
      # https://chromeenterprise.google/policies/?policy=${OPTION}
      "BrowserSignin" = 1;
      "SyncDisabled" = false;
      "PasswordManagerEnabled" = false;
      "SpellcheckEnabled" = true;
      "RestoreOnStartup" = 1; #
      "ForcedLanguages" = [
        "en-US"
        "de-DE"
        "ja-JP"
      ];
      "SpellcheckLanguage" = [
        "en-US"
        "de-DE"
        "ja-JP"
      ];
    };

    extensions = [
      # General
      "oldceeleldhonbafppcapldpdifcinji" # LanguageTool
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
      "pbcodcjpfjdpcineamnnmbkkmkdpajjg" # Link to Text Fragment
      "kdbmhfkmnlmbkgbabkdealhhbfhlmmon" # SteamDB
      "jinjaccalgkegednnccohejagnlnfdag" # Violentmonkey
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "cmpdlhmnmjhihmcfnigoememnffkimlk" # Catppuccin Macchiato

      # Japanese
      "dpaojegkimhndjkkgiaookhckojbmakd" # Jisho-OJAD
      "fgnpplmalkhmcilpgbngpmdgfnodknce" # jisho-pitcher
      "kjpdbjocmacakdfnngpkfjcjlkieogcf" # Jisho On The Fly
      "odedgbgofldomjnodnnjdlagjpmkjhnb" # Search Jisho

      # Social media
      "ajopnjidmegmdimjlfnijceegpefgped" # BetterTTV
      "jgejdcdoeeabklepnkdbglgccjpdgpmf" # Old Twitter Layout (2024)
      "kbmfpngjjgdllneeigpgjifpgocmfgmb" # Reddit Enhancement Suite
      "gebbhagfogifgggkldgodflihgfeippi" # Return YouTube Dislike
      "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
      "kfhgpagdjjoieckminnmigmpeclkdmjm" # Automatic Twitch
    ];

    enablePlasmaBrowserIntegration = true;
  };

  # Defaults
  xdg.mime.defaultApplications = {
    # Browser
    "text/html" = "chromium.desktop";
    "text/css" = "chromium.desktop";
    "text/xml" = "chromium.desktop";
    "text/plain" = "chromium.desktop";
    "application/xhtml+xml" = "chromium.desktop";
    "application/xml" = "chromium.desktop";
    "application/json" = "chromium.desktop";
    "application/javascript" = "chromium.desktop";
    "application/atom+xml" = "chromium.desktop";
    "application/rss+xml" = "chromium.desktop";
    "application/pdf" = "chromium.desktop";
    "application/x-shockwave-flash" = "chromium.desktop";
    "application/x-dmg" = "chromium.desktop";
    "application/x-mobipocket-ebook" = "chromium.desktop";
    "application/epub+zip" = "chromium.desktop";

    # MPV
    "audio/aac" = "mpv.desktop";
    "audio/ac3" = "mpv.desktop";
    "audio/AMR" = "mpv.desktop";
    "audio/AMR-WB" = "mpv.desktop";
    "audio/ape" = "mpv.desktop";
    "audio/basic" = "mpv.desktop";
    "audio/flac" = "mpv.desktop";
    "audio/midi" = "mpv.desktop";
    "audio/mp4" = "mpv.desktop";
    "audio/mpeg" = "mpv.desktop";
    "audio/ogg" = "mpv.desktop";
    "audio/opus" = "mpv.desktop";
    "audio/vnd.dts" = "mpv.desktop";
    "audio/vnd.dts.hd" = "mpv.desktop";
    "audio/x-aiff" = "mpv.desktop";
    "audio/x-ape" = "mpv.desktop";
    "audio/x-flac" = "mpv.desktop";
    "audio/x-matroska" = "mpv.desktop";
    "audio/x-mpegurl" = "mpv.desktop";
    "audio/x-ms-wma" = "mpv.desktop";
    "audio/x-musepack" = "mpv.desktop";
    "audio/x-pn-realaudio" = "mpv.desktop";
    "audio/x-scpls" = "mpv.desktop";
    "audio/x-speex" = "mpv.desktop";
    "audio/x-tta" = "mpv.desktop";
    "audio/x-wav" = "mpv.desktop";
    "audio/x-wavpack" = "mpv.desktop";
    "audio/x-xm" = "mpv.desktop";
    "video/3gpp" = "mpv.desktop";
    "video/3gpp2" = "mpv.desktop";
    "video/annodex" = "mpv.desktop";
    "video/avi" = "mpv.desktop";
    "video/divx" = "mpv.desktop";
    "video/flv" = "mpv.desktop";
    "video/h264" = "mpv.desktop";
    "video/mp2t" = "mpv.desktop";
    "video/mp4" = "mpv.desktop";
    "video/mpeg" = "mpv.desktop";
    "video/mpeg2" = "mpv.desktop";
    "video/msvideo" = "mpv.desktop";
    "video/ogg" = "mpv.desktop";
    "video/quicktime" = "mpv.desktop";
    "video/vnd.mpegurl" = "mpv.desktop";
    "video/webm" = "mpv.desktop";
    "video/x-flv" = "mpv.desktop";
    "video/x-matroska" = "mpv.desktop";
    "video/x-mng" = "mpv.desktop";
    "video/x-ms-asf" = "mpv.desktop";
    "video/x-ms-wmv" = "mpv.desktop";
    "video/x-msvideo" = "mpv.desktop";
    "video/x-nsv" = "mpv.desktop";
    "video/x-ogm+ogg" = "mpv.desktop";
  };

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

        # Media
        mpv

        # Browser
        chromium

        # Terminal
        kitty
        openssl

        # Editors
        vscode

        # Files
        nautilus

        # Hardware
        glxinfo
        lm_sensors
        gnome-disk-utility
        baobab

        # OS
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
      XMODIFIERS = "@im=fcitx";
      QT_IM_MODULE = "fcitx";
      GTK_IM_MODULE = "fcitx";
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

  programs.gamemode = {
    enable = true;
    settings = {
      custom = {
        start = "qdbus org.kde.KWin /Compositor suspend";
        stop = "qdbus org.kde.KWin /Compositor resume";
      };
    };
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

  services.libinput.mouse.accelProfile = "flat";

  # mullvad
  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.package = pkgs.mullvad-vpn;

  services.power-profiles-daemon.enable = true;
}
