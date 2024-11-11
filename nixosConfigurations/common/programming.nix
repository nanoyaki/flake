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
    hm.programs = {
      git = {
        enable = true;
        userName = "nanoyaki";
        userEmail = "hanakretzer@gmail.com";
      };

      neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        plugins = with pkgs.vimPlugins; [
          nvim-lspconfig
          nvim-treesitter.withAllGrammars
          nvim-cmp
        ];
      };
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
            rust-lang.rust-analyzer
            tamasfe.even-better-toml
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

    environment.variables = {
      EDITOR = lib.mkIf (!config.hm.programs.neovim.defaultEditor) "code";
      GIT_EDITOR = "code --wait --new-window";
    };

    programs.nix-ld.enable = cfg.enableCsharp;
  };
}
