{ inputs, ... }:

{
  flake.nixosConfigurations.kanokoyuri = inputs.nixpkgs.lib.nixosSystem {
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
      passkey
      kanokoyuri-system
      kanokoyuri-disks
      kanokoyuri-hardware
      kanokoyuri-openssh
      kanokoyuri-tailscale
      kanokoyuri-acme
      kanokoyuri-caddy
      kanokoyuri-zigbee2mqtt
      kanokoyuri-postgresql
      kanokoyuri-hass
      kanokoyuri-backups
    ];
  };

  flake.homeConfigurations.kanoko = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      inherit (inputs.self.nixosConfigurations.kanokoyuri.config.nixpkgs) config;
    };
    modules = with inputs.self.homeModules; [
      homeManager
      sops
      nix
      shell
      git
      passkey
      kanoko-system
    ];
  };

  flake.nixosModules.kanokoyuri-system =
    { config, ... }:

    {
      sops.defaultSopsFile = ./secrets.yaml;
      programs.nh.flake = "${config.self.mainUserHome}/flake";

      self.mainUser = "kanoko";
      self.mainUserHome = "/home/kanoko";
      sops.secrets."users/kanoko".neededForUsers = true;
      users.users.kanoko = {
        isNormalUser = true;
        description = "Kanoko";
        extraGroups = [ "wheel" ];
        hashedPasswordFile = config.sops.secrets."users/kanoko".path;
      };

      home-manager.users.kanoko.imports = with inputs.self.homeModules; [ kanoko-system ];
      home-manager.sharedModules = with inputs.self.homeModules; [
        homeManager
        sops
        nix
        shell
        git
        passkey
      ];

      nixpkgs.hostPlatform.system = "x86_64-linux";
      system.stateVersion = "25.11";
    };

  flake.homeModules.kanoko-system = {
    home.username = "kanoko";
    home.homeDirectory = "/home/kanoko";
    home.stateVersion = "26.05";
  };
}
