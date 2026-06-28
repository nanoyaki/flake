{ inputs, ... }:

{
  flake.nixosConfigurations.shirayuri = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with inputs.self.nixosModules; [
      common
      sops
      homeManager
      nix
      networking
      vopono
      shell
      locale
      git
      yubikey
      wayland
      fcitx5
      fonts
      audio
      plasma
      lact
      vscode
      theme
      catppuccin
      shirayuri-system
      shirayuri-cpu
      shirayuri-gpu
      shirayuri-cooling
      shirayuri-devices
      shirayuri-disks
      shirayuri-swap
      shirayuri-valveIndex
      shirayuri-cam
      shirayuri-headphones
      shirayuri-boot
      shirayuri-networking
      shirayuri-wireguard
      shirayuri-backups
      shirayuri-desktop
      shirayuri-firefox
      shirayuri-fcitx5
      shirayuri-gaming
      shirayuri-animeGames
      shirayuri-vr
      shirayuri-vrchat
      shirayuri-melee
    ];
  };

  flake.homeConfigurations.hana = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      inherit (inputs.self.nixosConfigurations.shirayuri.config.nixpkgs) config;
    };
    modules = with inputs.self.homeModules; [
      homeManager
      sops
      nix
      shell
      git
      yubikey
      plasma
      theme
      catppuccin
      hana-system
      hana-ssh
      hana-desktop
      hana-firefox
      hana-gaming
      hana-vr
      hana-vrchat
      hana-melee
    ];
  };

  flake.nixosModules.shirayuri-system =
    { config, ... }:

    {
      imports = [
        inputs.nixowos.nixosModules.default
      ];

      nixpkgs.overlays = [
        (final: _: { inherit (final.stable) fastfetch; })
      ];

      nixowos.enable = true;

      sops.defaultSopsFile = ./secrets.yaml;
      programs.nh.flake = "${config.self.mainUserHome}/flake";

      self.mainUser = "hana";
      self.mainUserHome = "/home/hana";
      sops.secrets."users/hana".neededForUsers = true;
      users.users.hana = {
        isNormalUser = true;
        description = "Hana";
        extraGroups = [ "wheel" ];
        hashedPasswordFile = config.sops.secrets."users/hana".path;
      };

      home-manager.users.hana.imports = with inputs.self.homeModules; [
        hana-system
        hana-ssh
        hana-desktop
        hana-firefox
        hana-gaming
        hana-vr
        hana-vrchat
        hana-melee
      ];
      home-manager.sharedModules = with inputs.self.homeModules; [
        homeManager
        sops
        nix
        shell
        git
        yubikey
        plasma
        theme
        catppuccin
      ];

      nixpkgs.hostPlatform.system = "x86_64-linux";
      nixpkgs.allowUnfreeNames = [
        # firefox addons
        "keepa"
        "languagetool"
        "tampermonkey"
        "betterttv"

        # desktop
        "steam"
        "steam-unwrapped"
        "osu-lazer-bin"
        "unityhub"
        "corefonts"
        "spotify"
        "discord"
        "vesktop"
        "unrar" # rar is unfree
      ];

      system.stateVersion = "24.11";
    };

  flake.homeModules.hana-system = {
    imports = [
      inputs.nixowos.homeModules.default
    ];

    nixowos.enable = true;

    home.username = "hana";
    home.homeDirectory = "/home/hana";

    nixpkgs.allowUnfreeNames = [
      "steam"
      "steam-unwrapped"
      "osu-lazer-bin"
      "spotify"
      "discord"
      "vesktop"
    ];

    home.stateVersion = "24.11";
  };
}
