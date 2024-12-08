{ deps, ... }:

{
  flake.nixosConfigurations = deps.mkSystem {
    hostname = "shirayuri";
    username = "hana";
    modules = [
      ../common

      ./hardware

      ./configuration.nix
      ./xdg-user-dirs.nix
      ./gaming
      ./emulation.nix
      ./vr
      ./shell.nix
      ./git.nix
    ];
  };
}
