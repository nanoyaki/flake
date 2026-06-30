{ inputs, ... }:

{
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

  flake.homeConfigurations.hana-kuroyuri = inputs.home-manager.lib.homeManagerConfiguration {
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
      hana-kuroyuri-system
      hana-kuroyuri-desktop
      hana-ssh
      hana-firefox
      hana-gaming
    ];
  };

  flake.nixosModules.kuroyuri-system =
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
        hana-kuroyuri-system
        hana-kuroyuri-desktop
        hana-ssh
        hana-firefox
        hana-gaming
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

      services.libinput.touchpad.naturalScrolling = true;

      nixpkgs.hostPlatform.system = "x86_64-linux";
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

      system.stateVersion = "24.11";
    };

  flake.homeModules.hana-kuroyuri-system = {
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
    ];

    home.stateVersion = "24.11";
  };
}
