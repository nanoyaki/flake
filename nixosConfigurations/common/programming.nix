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

        extraConfig = ''
          filetype plugin indent on
          set tabstop=4
          set shiftwidth=4
          set softtabstop=4
          set expandtab
        '';

        plugins = with pkgs.vimPlugins; [
          {
            plugin = pkgs.vimPlugins.nvim-lspconfig;
            type = "lua";
            config = ''
              local nvim_lsp = require("lspconfig")
              nvim_lsp.nixd.setup({
                cmd = { "nixd" },
                settings = {
                    nixd = {
                      nixpkgs = {
                          expr = "import <nixpkgs> { }",
                      },
                      formatting = {
                          command = { "nixfmt" },
                      },
                      options = {
                          nixos = {
                            expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.shirayuri.options',
                          },
                          home_manager = {
                            expr = '(builtins.getFlake ("git+file://" + toString ./.)).homeConfigurations.shirayuri.options',
                          },
                      },
                    },
                },
              })
            '';
          }
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
            denoland.vscode-deno
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "discord-vscode";
              publisher = "icrawl";
              version = "5.8.0";
              sha256 = "sha256-IU/looiu6tluAp8u6MeSNCd7B8SSMZ6CEZ64mMsTNmU=";
            }
            {
              name = "language-hugo-vscode";
              publisher = "budparr";
              version = "1.3.1";
              sha256 = "sha256-9dp8/gLAb8OJnmsLVbOAKAYZ5whavPW2Ak+WhLqEbJk=";
            }
          ];
      })
      (lib.mkIf cfg.enableCsharp jetbrains.rider)

      hugo
    ];

    environment.variables = {
      EDITOR = lib.mkIf (!config.hm.programs.neovim.defaultEditor) "code";
      GIT_EDITOR = "code --wait --new-window";
    };

    programs.nix-ld.enable = cfg.enableCsharp;
  };
}
