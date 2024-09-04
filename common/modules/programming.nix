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
        vscodeExtensions = with vscode-extensions;
          [
            bbenoist.nix
            kamadorueda.alejandra
            jnoortheen.nix-ide
            catppuccin.catppuccin-vsc
            catppuccin.catppuccin-vsc-icons
            dbaeumer.vscode-eslint
            esbenp.prettier-vscode
            tamasfe.even-better-toml
            rust-lang.rust-analyzer
            prisma.prisma
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "javascript-ejs-support";
              publisher = "DigitalBrainstem";
              version = "1.3.3";
              sha256 = "0s2xazs74j7dgq1ndakfgami3kxk758ydqsgswixcv80705pbxjn";
            }
          ];
      })
    ];

    # VCS
    programs.git.enable = true;
  };
}
