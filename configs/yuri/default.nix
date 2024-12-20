{ deps, ... }:

{
  flake.nixosConfigurations = deps.mkSystem {
    hostname = "yuri";
    username = "nas";
    modules = [
      ../common/sops
      ../common/home.nix
      ../common/user.nix
      ../common/networking.nix
      ../common/nix.nix
      ../common/shell.nix

      ./hardware
      ./configuration.nix
      ./ssh.nix
      ./locale.nix
    ];
  };
}
