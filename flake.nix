{
  description = "Hana's NixOS System flake";

  # Use lfs once nightly nix is stable

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flatpaks.url = "github:in-a-dil-emma/declarative-flatpak";
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    prismlauncher = {
      url = "github:PrismLauncher/PrismLauncher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-minecraft = {
      url = "github:nanoyaki/nix-minecraft/neoforge-master-base";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    lazy-apps = {
      url = "sourcehut:~rycee/lazy-apps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    valheim-server = {
      url = "github:hamburger1984/valheim-server-flake/beta";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snm = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-25_05.follows = "nixpkgs-stable";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    copyparty = {
      url = "github:9001/copyparty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wkeys = {
      url = "github:nanoyaki/wkeys?dir=wkeys";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    cosmic-manager = {
      url = "github:HeitorAugustoLN/cosmic-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
    };

    # own stuff
    vermeer-undervolt = {
      url = "github:nanoyaki/5800x3d-undervolt/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    discord-events-to-ics = {
      url = "github:nanoyaki/discord-events-to-ics";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    nanopkgs = {
      url = "github:nanoyaki/nanopkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    killheal.url = "git+https://git.theless.one/thelessone/KillHeal.git";
    nanolib = {
      url = "git+https://git.theless.one/nanoyaki/nanolib.git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    nanomodules = {
      url = "git+https://git.theless.one/nanoyaki/nanomodules.git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nanolib.follows = "nanolib";
    };
    # eh, i don't use it that much anyway
    # owned-material.url = "git+ssh://git@git.theless.one/nanoyaki/owned-material.git?ref=main&lfs=1";
  };

  outputs =
    inputs@{
      flake-parts,
      ...
    }:

    flake-parts.lib.mkFlake { inherit inputs; } {
      _module.args.lib' = inputs.nanolib.lib;

      imports = [
        inputs.git-hooks-nix.flakeModule
        ./modules

        ./configs/shirayuri
        ./configs/kuroyuri
        ./configs/yuri
        ./configs/yamayuri
        ./configs/himeyuri
      ];

      perSystem =
        {
          lib,
          pkgs,
          self',
          config,
          ...
        }:

        let
          inherit (lib) mapAttrs' nameValuePair;
        in

        {
          pre-commit = {
            check.enable = true;
            settings.hooks = {
              statix.enable = true;
              flake-checker.enable = true;
              nixfmt-rfc-style.enable = true;
              deadnix.enable = true;
            };
          };

          devShells.default = config.pre-commit.devShell.overrideAttrs (prevAttrs: {
            buildInputs = (prevAttrs.buildInputs or [ ]) ++ (with pkgs; [ git ]);
          });

          checks = mapAttrs' (n: nameValuePair "devShell-${n}") self'.devShells;

          formatter = pkgs.nixfmt-tree;
        };

      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
}
