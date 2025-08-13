{
  lib,
  lib',
  pkgs,
  config,
  ...
}:

let
  inherit (lib) mkIf mkDefault;
  inherit (lib'.options) mkFalseOption;

  cfg = config.config'.theming.stylix;
in

{
  options.config'.theming.stylix = {
    enable = mkFalseOption;
    enableAutoStylix = mkFalseOption;
  };

  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = cfg.enableAutoStylix;

      cursor = {
        package = pkgs.rose-pine-cursor;
        name = "BreezeX-RosePine-Linux";
        size = 32;
      };

      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-${
        config.config'.theming.catppuccin.flavor or "mocha"
      }.yaml";
      polarity = "dark";

      image = mkDefault (
        pkgs.fetchurl {
          url = "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:majihettvb7ieflgmkvujecu/bafkreifj2it2zsr4x5iiv7ti5hcf7l3bwoym6fn2xn7mygohsm4sptcgbu";
          hash = "sha256-uuoCCTDvuzowPdQAjFno2XZMLWtJIPXX/i/Ko0AONaY=";
        }
      );

      targets.plymouth = { inherit (config.boot.plymouth) enable; };
    };
  };
}
