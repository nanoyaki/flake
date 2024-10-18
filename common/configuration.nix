{
  pkgs,
  lib,
  username,
  inputs,
  config,
  ...
}:

{
  imports = [
    ./sops/sops.nix
    ./modules/plasma.nix
    ./modules/gnome.nix
    ./modules/mpv.nix
    ./modules/chrome.nix
    ./modules/audio.nix
    ./modules/terminal.nix
    ./modules/files.nix
    ./modules/programming.nix
    ./modules/input.nix
  ];

  boot = {
    loader.efi = {
      canTouchEfiVariables = lib.mkDefault true;
      efiSysMountPoint = "/boot/efi";
    };
    loader.grub = {
      catppuccin.enable = true;
      catppuccin.flavor = "macchiato";
      configurationLimit = 35;
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
    };
    supportedFilesystems = [ "ntfs" ];
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  };

  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.networkmanager.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    description = "Hana";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "audio"
      "uinput"
      "jackaudio"
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

  time.hardwareClockInLocalTime = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LANGUAGE = "en_GB";
    LC_ALL = "de_DE.UTF-8";
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

  environment.variables.FLAKE_DIR = "$HOME/flake";

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
        monospace = [ "Cascadia Mono" ];
      };
    };
  };

  catppuccin.enable = true;
  catppuccin.accent = "pink";
  catppuccin.flavor = "macchiato";

  services.xserver.enable = true;

  services.displayManager.autoLogin = {
    enable = true;
    user = username;
  };

  modules = {
    audio = {
      enable = true;
      latency = 32;
    };
    plasma6.enable = true;
    terminal.enable = true;
    files.enable = true;
    chrome.enable = true;
    mpv.enable = true;
    programming.enable = true;
    input.enable = true;
  };

  environment.systemPackages =
    (with pkgs; [
      glxinfo
      lm_sensors
    ])
    ++ [
      (import ./rebuild.nix { inherit pkgs config username; })
      (import ./nix-up.nix { inherit pkgs config username; })
    ];

  home-manager = {
    sharedModules = [
      inputs.plasma-manager.homeManagerModules.plasma-manager
      inputs.catppuccin.homeManagerModules.catppuccin
    ];

    backupFileExtension = "home-bac";
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${username}.imports = [ ./home.nix ];
  };

  system.stateVersion = "24.05";
}
