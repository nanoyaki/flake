{
  lib,
  lib',
  config,
  ...
}:

let
  inherit (lib) mkIf mkDefault;
  inherit (lib'.options) mkFalseOption;

  cfg = config.config'.theming;
in

{
  options.config'.theming.enable = mkFalseOption;

  imports = [
    ./boot.nix
    ./stylix.nix
    ./catppuccin.nix
    ./gtk.nix
    ./cosmic.nix
  ];

  config = mkIf cfg.enable {
    config'.theming = {
      gtk.enable = mkDefault true;
      plymouth.enable = mkDefault true;
      catppuccin.enable = mkDefault true;
      stylix.enable = mkDefault true;
    };
  };
}
