{ deps, ... }:

{
  flake.nixosConfigurations = deps.mkSystem {
    hostname = "shirayuri";
    username = "hana";
    modules = [
      ../common
      ../common/vr
      ../common/gaming

      ./hardware

      ./configuration.nix
      ./xdg-user-dirs.nix
      ./gaming
      ./emulation.nix
      ./shell.nix
      ./git.nix
    ];
  };
}
