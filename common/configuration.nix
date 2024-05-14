# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
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
        configurationLimit = 35;
        enable = true;
        efiSupport = true;
        device = "nodev";
      };
    };
    supportedFilesystems = ["ntfs"];
    #kernelPackages = pkgs.linuxPackages_latest;
  };

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  #services.desktopManager.plasma6.enable = true;
  environment.plasma5.excludePackages = with pkgs; [
    kdePackages.konsole
    kdePackages.dolphin
    kdePackages.kate
    kdePackages.elisa
    kdePackages.kwrited
    kdePackages.kwallet
    kdePackages.ark
    kdePackages.okular
    kdePackages.print-manager
  ];
  programs.kdeconnect.enable = false;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Keyboard input
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
    ];
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    package = pkgs.stable.pipewire;
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  environment.etc."pipewire/pipewire.conf.d/99-rates.conf".text = ''
    context.properties = {
      default.clock.rate = 48000
      default.clock.quantum = 32
      default.clock.min-quantum = 32
      default.clock.max-quantum = 32
    }
  '';

  # I HAVE NO FUCKING IDEA HOW TO MAKE OSU LAZER USE A 48K SAMPLE RATE

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hana = {
    isNormalUser = true;
    description = "Hana";
    extraGroups = ["networkmanager" "wheel" "input" "jackaudio"];
  };

  security.sudo.extraRules = [
    {
      users = ["hana"];
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
    user = "hana";
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Zshell
  users.defaultUserShell = pkgs.zsh;

  environment.pathsToLink = ["/share/zsh"];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # https://search.nixos.org/packages?channel=unstable
  environment.systemPackages = with pkgs; [
    # Programming
    rustup
    python3
    libgcc
    gcc
    gnumake
    gh
    alejandra

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
    pipewire.jack

    # OS
    (import ./rebuild.nix {inherit pkgs;})
    gtk4
    gtk3
  ];

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
  security.polkit.enable = true;
  # Corectrl
  security.polkit.extraConfig = ''
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

  # General hardware control
  programs.corectrl = {
    enable = true;
    gpuOverclock.enable = true;
    gpuOverclock.ppfeaturemask = "0xffffffff";
  };

  programs.coolercontrol.enable = true;

  # Environment variables
  environment.sessionVariables = {
    PIPEWIRE_LATENCY = "32/48000";
    FLAKE_DIR = "$HOME/flake";
    LANGUAGE = "en_GB";
  };
  environment.variables = {
    EDITOR = "code";
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
      nix-up = "sudo nixos-rebuild switch --upgrade";
      nix-op = "firefox \"https://search.nixos.org/options?channel=unstable\"";
      nix-pac = "firefox \"https://search.nixos.org/packages?channel=unstable\"";
      nix-hom = "firefox \"https://home-manager-options.extranix.com/\"";
      nya = "cat";
      yt = "firefox youtube.com";
    };
    histSize = 10000;
  };

  # Nautilus Settings
  programs.nautilus-open-any-terminal.enable = true;
  programs.nautilus-open-any-terminal.terminal = "kitty";

  # Gaming
  services.monado = {
    enable = true;
    defaultRuntime = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamemode.enable = true;
  services.libinput.mouse.accelProfile = "flat";

  # mullvad
  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.package = pkgs.mullvad-vpn;
}
