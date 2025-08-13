{
  lib,
  lib',
  pkgs,
  config,
  inputs,
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

      image = mkDefault inputs.owned-material.images.szcb911."2024-10-15.jpeg";

      targets.plymouth = { inherit (config.boot.plymouth) enable; };
    };
  };
}
