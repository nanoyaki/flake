{ deps, ... }:

{
  flake.nixosConfigurations = deps.mkSystem {
    hostname = "server-nixos";
    username = "thelessone";
    modules = [
      ../common/sops
      ../common/home.nix
      ../common/nix.nix
      ../common/user.nix
      ../common/networking.nix
      ../common/audio.nix
      ../common/input.nix
      ../common/programming.nix
      ../common/shell.nix

      ./hardware

      ./firewall.nix
      ./gnome.nix
      ./configuration.nix
      ./programming.nix
      ./git.nix
      ./locale.nix
      ./minecraft
      ./servers
    ];
  };
}
