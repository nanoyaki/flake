{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:

let
  inherit (inputs) nvf;
in

{
  imports = [ nvf.nixosModules.default ];

  programs.nvf = {
    enable = true;

    settings.vim = {
      theme = {
        enable = true;
        name = "catppuccin";
        style = "mocha";
      };

      statusline.lualine.enable = true;
      telescope.enable = true;
      autocomplete.nvim-cmp.enable = true;
      presence.neocord.enable = true;
      globals.editorconfig = true;

      languages = {
        enableLSP = true;
        enableTreesitter = true;

        sql.enable = true;
        php.enable = true;
        html.enable = true;
        css.enable = true;
        python.enable = true;

        markdown.enable = true;
        bash.enable = true;
        rust.enable = true;

        nix.enable = true;
        nix.format = {
          enable = true;
          type = "nixfmt";
          package = pkgs.nixfmt-rfc-style;
        };
      };

      lazy.plugins."yazi.nvim" = {
        package = pkgs.vimPlugins.yazi-nvim;
        setupModule = "yazi";
        setupOpts.open_for_directories = false;
        keys = [
          {
            mode = "n";
            key = "<leader>y";
            action = ''
              function()
                require("yazi").yazi()
              end
            '';
            lua = true;
            desc = "Open yazi";
          }
          {
            mode = "n";
            key = "<leader>cy";
            action = ''
              function()
                require("yazi").yazi(nil, vim.fn.getcwd())
              end
            '';
            lua = true;
            desc = "Open yazi in working directory (yazi)";
          }
        ];
      };
    };
  };

  environment.variables.EDITOR = lib.getExe config.programs.nvf.settings.vim.package;
  environment.systemPackages = [ pkgs.yazi ];
}
