{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.modules.programming;
in {
  options.modules.programming = {
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
            tamasfe.even-better-toml
            rust-lang.rust-analyzer
            prisma.prisma
            eamodio.gitlens
            biomejs.biome
            ms-vscode-remote.remote-ssh
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "javascript-ejs-support";
              publisher = "DigitalBrainstem";
              version = "1.3.3";
              sha256 = "0s2xazs74j7dgq1ndakfgami3kxk758ydqsgswixcv80705pbxjn";
            }
            {
              name = "bun-vscode";
              publisher = "oven";
              version = "0.0.12";
              sha256 = "sha256-8+Fqabbwup6Jzm5m8GlWbxTqumqXtWAw5s3VaDht9Us=";
            }
            {
              name = "discord-vscode";
              publisher = "icrawl";
              version = "5.8.0";
              sha256 = lib.fakeSha256;
            }
          ];
      })
    ];

    # VCS
    programs.git.enable = true;
  };
}
