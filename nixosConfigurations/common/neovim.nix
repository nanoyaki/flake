{ pkgs, ... }:

let
  nvimLspExtraConfig = ''
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
in

{
  hm.programs.neovim = {
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
        config = nvimLspExtraConfig;
      }
      nvim-treesitter.withAllGrammars
      nvim-cmp
    ];
  };
}
