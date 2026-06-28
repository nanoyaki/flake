{ inputs, ... }:

{
  flake.nixosModules.shirayuri-melee = _: {
    imports = [ inputs.slippi.nixosModules.default ];

    nix.settings.extra-substituters = [ "https://slippi-nix.cachix.org" ];
    nix.settings.extra-trusted-public-keys = [
      "slippi-nix.cachix.org-1:2qnPHiOxTRpzgLEtx6K4kXq/ySDg7zHEJ58J6xNDvBo="
    ];
  };

  flake.homeModules.hana-melee = _: {
    imports = [ inputs.slippi.homeManagerModules.default ];

    slippi-launcher = {
      enable = true;
      isoPath = "/mnt/os-shared/Games/melee.iso";
      launchMeleeOnPlay = true;
    };
  };
}
