# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  lib,
  username,
  ...
}:
{
  imports = [
    ./modules/plasma.nix
    ./modules/gnome.nix
    ./modules/mpv.nix
    ./modules/chrome.nix
    ./modules/audio.nix
    ./modules/terminal.nix
    ./modules/files.nix
    ./modules/programming.nix
  ];

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
    supportedFilesystems = [ "ntfs" ];
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  };
  time.hardwareClockInLocalTime = true;

  # Nix settings
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # User
  users.users.${username} = {
    isNormalUser = true;
    description = "Hana";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "audio"
      "uinput"
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "${username}" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

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

  # Fonts
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      cascadia-code
      noto-fonts
      noto-fonts-cjk
      mplus-outline-fonts.githubRelease
    ];

    fontconfig = {
      antialias = true;
      defaultFonts = {
        serif = [ "M PLUS 2" ];
        sansSerif = [ "M PLUS 2" ];
      };
    };
  };

  # Keyboard input
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
      waylandFrontend = true;
    };
  };

  # For fcitx autostart
  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.displayManager.autoLogin = {
    enable = true;
    user = username;
  };

  modules = {
    audio = {
      enable = true;
      latency = 512;
    };
    plasma6.enable = true;
    terminal.enable = true;
    files.enable = true;
    chrome.enable = true;
    mpv.enable = true;
    programming.enable = true;
  };

  # Theming
  catppuccin.enable = true;
  catppuccin.accent = "pink";
  catppuccin.flavor = "macchiato";

  # Input
  services.libinput.mouse.accelProfile = "flat";
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  environment.sessionVariables = {
    XMODIFIERS = "@im=fcitx";
    QT_IM_MODULE = "fcitx";
    GTK_IM_MODULE = "fcitx";

    LANGUAGE = "en_GB";
  };

  environment.variables = {
    XMODIFIERS = "@im=fcitx";
    QT_IM_MODULE = "fcitx";
    GTK_IM_MODULE = "fcitx";

    FLAKE_DIR = "$HOME/flake";
    EDITOR = "code";

    LANGUAGE = "en_GB";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # https://search.nixos.org/packages?channel=unstable
  # Environment
  environment.systemPackages =
    (with pkgs; [
      # Hardware
      glxinfo
      lm_sensors
    ])
    ++ [
      (import ./rebuild.nix { inherit pkgs; })
      (import ./nix-up.nix { inherit pkgs; })
    ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
