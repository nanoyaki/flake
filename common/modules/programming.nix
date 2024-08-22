{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.services.nano.programming;
in {
  options.services.nano.programming = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable VCS and IDE options.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Programming
      gh
      alejandra
      nil

      # Editors
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          bbenoist.nix
          kamadorueda.alejandra
          jnoortheen.nix-ide
          catppuccin.catppuccin-vsc
          catppuccin.catppuccin-vsc-icons
          dbaeumer.vscode-eslint
          esbenp.prettier-vscode
        ];
      })
    ];

    # VCS
    programs.git.enable = true;
  };
}
