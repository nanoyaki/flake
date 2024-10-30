{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption;

  cfg = config.modules.programming;
in

{
  options.modules.programming.enableCsharp = mkEnableOption "csharp required options";

  config = {
    hm.programs.git = {
      enable = true;
      userName = "nanoyaki";
      userEmail = "hanakretzer@gmail.com";
    };

    programs.git.enable = true;

    environment.systemPackages = with pkgs; [
      gh
      nixfmt-rfc-style
      nixd

      (vscode-with-extensions.override {
        vscodeExtensions =
          with pkgs.vscode-extensions;
          [
            jnoortheen.nix-ide
            catppuccin.catppuccin-vsc
            catppuccin.catppuccin-vsc-icons
            eamodio.gitlens
            ms-vscode-remote.remote-ssh
            editorconfig.editorconfig
            hediet.vscode-drawio
            yzhang.markdown-all-in-one
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "discord-vscode";
              publisher = "icrawl";
              version = "5.8.0";
              sha256 = "sha256-IU/looiu6tluAp8u6MeSNCd7B8SSMZ6CEZ64mMsTNmU=";
            }
          ];
      })
      (lib.mkIf cfg.enableCsharp jetbrains.rider)
    ];

    environment.variables.EDITOR = "code";

    programs.nix-ld.enable = cfg.enableCsharp;
  };
}
