{ deps, ... }:

{
  flake.nixosConfigurations = deps.mkSystem {
    hostname = "shirayuri";
    modules = [
      ../common

      ./hardware

      ./boot.nix
      ./xdg-user-dirs.nix
      ./gaming
      ./emulation.nix
      ./vr
      ./configuration.nix
    ];
  };
}
