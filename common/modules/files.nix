{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.services.nano.files;
in {
  options.services.nano.files = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable custom file management options.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Files
      unrar
      unzip
      p7zip

      # Space
      ncdu
    ];

    # Archive manager
    programs.file-roller.enable = true;
  };
}
