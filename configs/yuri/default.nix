{ deps, ... }:

{
  flake.nixosConfigurations = deps.mkSystem {
    hostname = "yuri";
    username = "nas";
    modules = [
      ../common/required
      ../common/optional/shell-utils.nix
      ../common/optional/ssh-settings.nix
      ../common/optional/deployment.nix

      ./hardware
      ./configuration.nix
      ./ssh.nix
      ./servers
      ./deployment.nix
    ];
  };
}
