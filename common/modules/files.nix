{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.files;
in

{
  options.modules.files = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable custom file management options.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      unrar
      unzip
      p7zip

      ncdu

      gnome-disk-utility
    ];

    environment.sessionVariables.XDG_CONFIG_HOME = "$HOME/.config";

    # Archive manager
    programs.file-roller.enable = true;
  };
}
