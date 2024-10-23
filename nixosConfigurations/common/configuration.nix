{
  pkgs,
  lib,
  username,
  config,
  inputs,
  ...
}:

{
  imports = [
    # See https://github.com/Scrumplex/flake/blob/main/nixosConfigurations/common/home.nix#L16
    (lib.modules.mkAliasOptionModule [ "hm" ] [
      "home-manager"
      "users"
      username
    ])
    ./home.nix

    ../../sops/sops.nix
    ../../nixosModules/theme.nix
    ../../nixosModules/nanoLib.nix
    ../../nixosModules/plasma.nix
    ../../nixosModules/mpv.nix
    ../../nixosModules/chrome.nix
    ../../nixosModules/audio.nix
    ../../nixosModules/terminal.nix
    ../../nixosModules/files.nix
    ../../nixosModules/programming.nix
    ../../nixosModules/input.nix
  ];

  boot = {
    loader.efi = {
      canTouchEfiVariables = lib.mkDefault true;
      efiSysMountPoint = "/boot/efi";
    };
    loader.grub = {
      configurationLimit = 35;
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
    };
    supportedFilesystems = [ "ntfs" ];
    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod;
  };

  nixpkgs.config.allowUnfree = true;

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

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
      noto-fonts-cjk-sans
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

  services.xserver.enable = true;

  services.displayManager.autoLogin = {
    enable = true;
    user = username;
  };

  modules.audio.latency = 32;

  environment.systemPackages =
    (with pkgs; [
      glxinfo
      lm_sensors
    ])
    ++ [
      (import ../../pkgs/rebuild/package.nix { inherit pkgs config; })
      (import ../../pkgs/nix-up/package.nix { inherit pkgs config; })
    ];

  system.stateVersion = "24.11";
}
