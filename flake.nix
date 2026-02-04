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
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
        pre-commit.follows = "pre-commit-hooks";
      };
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        gitignore.follows = "gitignore";
      };
    };
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        lib-aggregate.follows = "lib-aggregate";
      };
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
        systems.follows = "systems";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
        flake-compat.follows = "flake-compat";
      };
    };
    lazy-apps = {
      url = "sourcehut:~rycee/lazy-apps";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks";
    };
    # TODO
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
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
    nanopkgs = {
      url = "git+https://git.theless.one/nanoyaki/nanopkgs.git";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        git-hooks-nix.follows = "git-hooks-nix";
        flake-compat.follows = "flake-compat";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    nanolib = {
      url = "git+https://git.theless.one/nanoyaki/nanolib.git";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        systems.follows = "systems";
      };
    };
    nanomodules = {
      url = "git+https://git.theless.one/nanoyaki/nanomodules.git";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        nanolib.follows = "nanolib";
        systems.follows = "systems";
      };
    };
    vermeer-undervolt = {
      url = "github:nanoyaki/5800x3d-undervolt/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    discord-events-to-ics = {
      url = "github:nanoyaki/discord-events-to-ics";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        systems.follows = "systems";
      };
    };

    # deduplicated deps
    flake-compat.url = "github:NixOS/flake-compat";
    systems.url = "github:nix-systems/default-linux";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        gitignore.follows = "gitignore";
      };
    };
    lib-aggregate = {
      url = "github:nix-community/lib-aggregate";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig.extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
  nixConfig.extra-trusted-public-keys = [
    "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
  ];

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
