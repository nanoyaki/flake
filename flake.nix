{
  inputs = {
    # Essentials
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    import-tree.url = "github:vic/import-tree";
    systems.url = "github:nix-systems/default-linux";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    cosmic-manager.url = "github:HeitorAugustoLN/cosmic-manager";
    cosmic-manager.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-parts.follows = "flake-parts";
      home-manager.follows = "home-manager";
    };
    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs = {
      nixpkgs.follows = "nixpkgs";
      home-manager.follows = "home-manager";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nixpkgs-wayland.inputs = {
      nixpkgs.follows = "nixpkgs";
      lib-aggregate.follows = "lib-aggregate";
      flake-compat.follows = "flake-compat";
    };
    vermeer-undervolt.url = "github:nanoyaki/5800x3d-undervolt";
    vermeer-undervolt.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
    nur.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-parts.follows = "flake-parts";
    };
    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
    nixpkgs-xr.inputs = {
      nixpkgs.follows = "nixpkgs";
      systems.follows = "systems";
      flake-utils.follows = "flake-utils";
      flake-compat.follows = "flake-compat";
    };
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    git-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";
    git-hooks-nix.inputs.flake-compat.follows = "flake-compat";
    nixowos.url = "github:yunfachi/NixOwOS";
    nixowos.inputs = {
      flake-parts.follows = "flake-parts";
      flake-compat.follows = "flake-compat";
      git-hooks.follows = "git-hooks-nix";
      nixpkgs.follows = "nixpkgs";
      systems.follows = "systems";
    };
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    pedantix.url = "github:Swarsel/pedantix";
    pedantix.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-parts.follows = "flake-parts";
      treefmt-nix.follows = "treefmt-nix";
      git-hooks-nix.follows = "git-hooks-nix";
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Deduplication
    flake-compat.url = "github:NixOS/flake-compat";
    flake-compat.flake = false;
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";
    lib-aggregate.url = "github:nix-community/lib-aggregate";
    lib-aggregate.inputs = {
      flake-utils.follows = "flake-utils";
      nixpkgs-lib.follows = "nixpkgs";
    };
    gitignore.url = "github:hercules-ci/gitignore.nix";
    gitignore.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./nix);
}
