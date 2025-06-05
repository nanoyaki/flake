{
  lib',
  ...
}:

{
  flake.nixosConfigurations = lib'.mkSystem {
    hostname = "thelessnas";
    username = "admin";
    modules = [
      ../common/required
      ../common/optional/shell-utils.nix
      ../common/optional/deployment.nix

      ./hardware

      ./configuration.nix
      ./openssh.nix
      ./samba.nix
    ];
  };
}
