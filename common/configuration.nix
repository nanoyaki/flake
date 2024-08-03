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
  imports = [
    ./modules/plasma.nix
    ./modules/mpv.nix
    ./modules/chrome.nix
    ./modules/audio.nix
    ./modules/terminal.nix
    ./modules/files.nix
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
    supportedFilesystems = ["ntfs"];
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  };
  time.hardwareClockInLocalTime = true;

  # Nix settings
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Enable networking
  networking.networkmanager.enable = true;

  # User
  users.users.${username} = {
    isNormalUser = true;
    description = "Hana";
    extraGroups = ["networkmanager" "wheel" "input" "audio" "uinput"];
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "${username}";
    };
  };

  programs.neovim.enable = true;

  # Desktop Manager
  services.nano.plasma6.enable = true;

  # Input
  services.libinput.mouse.accelProfile = "flat";
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Kanata custom config
  services.kanata = {
    enable = true;
    keyboards.default = {
      devices = [
        "/dev/input/by-id/usb-Cooler_Master_Technology_Inc._SK650-event-kbd"
      ];

      config = ''
        (defsrc
          caps
        )

        (defalias
          escctrl (tap-hold 100 100 esc lctrl)
        )

        (deflayer base
          @escctrl
        )
      '';
    };
  };

  # Shell
  services.nano.terminal.enable = true;

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
    EDITOR = "nvim";

    LANGUAGE = "en_GB";
  };

  # Audio
  services.nano.audio.enable = true;

  # Audio and video player
  services.nano.mpv.enable = true;

  # Theming
  catppuccin.enable = true;
  catppuccin.accent = "pink";
  catppuccin.flavor = "macchiato";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Browser
  services.nano.chrome.enable = true;

  # Files
  services.nano.files.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # https://search.nixos.org/packages?channel=unstable
  # TODO: make this modular
  # Environment
  environment.systemPackages =
    (with pkgs; [
      # Programming
      gh
      alejandra
      nil

      # Editors
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          bbenoist.nix
          kamadorueda.alejandra
          jnoortheen.nix-ide
          catppuccin.catppuccin-vsc
          catppuccin.catppuccin-vsc-icons
        ];
      })

      # Hardware
      glxinfo
      lm_sensors

      # GTK
      gtk4
    ])
    ++ [
      (import ./rebuild.nix {inherit pkgs;})
      (import ./nix-up.nix {inherit pkgs;})
    ];

  # vcs
  programs.git.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
