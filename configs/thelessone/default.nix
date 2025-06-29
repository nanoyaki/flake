{
  lib',
  ...
}:

{
  flake.nixosConfigurations = lib'.mkSystem {
    hostname = "thelessone";
    username = "thelessone";
    modules = [
      ../common/required
      ../common/optional/fonts.nix
      ../common/optional/shell-utils.nix
      ../common/optional/browsers/firefox.nix
      ../common/optional/deployment.nix
      ../common/optional/cuda.nix
      ../common/optional/norgb.nix

      ./hardware

      ./firewall.nix
      ./gnome.nix
      ./configuration.nix
      ./git.nix
      ./servers
      ./terminal.nix
      ./deployment.nix
      # ./mullvad.nix
      ./tailscale.nix
      ./vaultwarden.nix
      ./beets.nix
      ./zfs.nix
    ];
  };
}
