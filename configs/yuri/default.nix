{ deps, ... }:

{
  flake.nixosConfigurations = deps.mkSystem {
    hostname = "yuri";
    username = "nas";
    modules = [
      ../common/sops.nix
      ../common/home.nix
      ../common/user.nix
      ../common/networking.nix
      ../common/nix.nix
      ../common/shell.nix
      ../common/ssh.nix

      ./hardware
      ./configuration.nix
      ./ssh.nix
      ./locale.nix
      ./servers
    ];
  };
}
