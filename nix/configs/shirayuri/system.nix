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
      shirayuri-boot
      shirayuri-networking
      shirayuri-wireguard
      shirayuri-backups
      shirayuri-desktop
      shirayuri-librewolf
      shirayuri-fcitx5
      shirayuri-gaming
      shirayuri-animeGames
      shirayuri-vr
      shirayuri-vrchat
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
      hana-librewolf
      hana-gaming
      hana-vr
      hana-vrchat
    ];
  };

  flake.nixosModules.shirayuri-system =
    { config, ... }:

    {
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
        hana-librewolf
        hana-gaming
        hana-vr
        hana-vrchat
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
      ];

      system.stateVersion = "24.11";
    };

  flake.homeModules.hana-system = {
    home.username = "hana";
    home.homeDirectory = "/home/hana";

    nixpkgs.allowUnfreeNames = [
      "steam"
      "steam-unwrapped"
      "osu-lazer-bin"
      "spotify"
    ];

    home.stateVersion = "24.11";
  };
}
