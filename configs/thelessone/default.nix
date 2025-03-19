{
  deps,
  ...
}:

{
  flake.nixosConfigurations = deps.mkSystem {
    hostname = "thelessone";
    username = "thelessone";
    modules = [
      ../common/required
      ../common/optional/fonts.nix
      ../common/optional/shell-utils.nix
      ../common/optional/browsers/firefox.nix
      ../common/optional/deployment.nix

      ./hardware

      ./firewall.nix
      ./gnome.nix
      ./configuration.nix
      ./git.nix
      ./servers
      ./terminal.nix
      # ./mullvad.nix
    ];
  };
}
