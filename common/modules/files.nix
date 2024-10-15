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
    ];

    # Archive manager
    programs.file-roller.enable = true;
  };
}
