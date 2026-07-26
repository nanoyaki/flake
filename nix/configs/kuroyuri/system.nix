{ inputs, ... }:

{
  flake.homeConfigurations.hana-kuroyuri = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      inherit (inputs.self.nixosConfigurations.shirayuri.config.nixpkgs) config;
      system = "x86_64-linux";
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
      hana-kuroyuri-system
      hana-kuroyuri-desktop
      hana-ssh
      hana-firefox
      hana-gaming
    ];
  };

  flake.homeModules.hana-kuroyuri-system = {
    imports = [
      inputs.nixowos.homeModules.default
    ];

    nixpkgs.allowUnfreeNames = [
      "steam"
      "steam-unwrapped"
      "osu-lazer-bin"
    ];

    nixowos.enable = true;
    home.homeDirectory = "/home/hana";
    home.stateVersion = "24.11";
    home.username = "hana";
  };

  flake.nixosConfigurations.kuroyuri = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = with inputs.self.nixosModules; [
      common
      sops
      homeManager
      nix
      networking
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
      kuroyuri-system
      kuroyuri-boot
      kuroyuri-cpu
      kuroyuri-gpu
      kuroyuri-drives
      kuroyuri-power
      kuroyuri-networking
    ];
  };

  flake.nixosModules.kuroyuri-system =
    { config, ... }:

    {
      imports = [
        inputs.nixowos.nixosModules.default
      ];

      nixpkgs.allowUnfreeNames = [
        # firefox addons
        "keepa"
        "languagetool"
        "tampermonkey"
        "betterttv"
        "unityhub"

        # desktop
        "steam"
        "steam-unwrapped"
        "osu-lazer-bin"
        "corefonts"
        "unrar" # rar is unfree
      ];

      nixpkgs.hostPlatform.system = "x86_64-linux";

      nixpkgs.overlays = [
        (final: _: { inherit (final.stable) fastfetch; })
      ];

      sops.defaultSopsFile = ./secrets.yaml;
      sops.secrets."users/hana".neededForUsers = true;

      users.users.hana = {
        description = "Hana";
        extraGroups = [ "wheel" ];
        hashedPasswordFile = config.sops.secrets."users/hana".path;
        isNormalUser = true;
      };

      services.libinput.touchpad.naturalScrolling = true;
      programs.nh.flake = "${config.self.mainUserHome}/flake";

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

      home-manager.users.hana.imports = with inputs.self.homeModules; [
        hana-kuroyuri-system
        hana-kuroyuri-desktop
        hana-ssh
        hana-firefox
        hana-gaming
      ];

      nixowos.enable = true;
      self.mainUser = "hana";
      self.mainUserHome = "/home/hana";
      system.stateVersion = "24.11";
    };
}
