{
  flake.nixosModules.zed =
    { lib, pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [
        zed-editor
        nixd
      ];

      environment.sessionVariables = {
        EDITOR = lib.getExe pkgs.zed-editor;
        GIT_EDITOR = "${lib.getExe pkgs.zed-editor} --wait";
        SOPS_EDITOR = "${lib.getExe pkgs.zed-editor} --wait";
      };
    };

  flake.homeModules.zed =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [ vscode-json-languageserver ];

      programs.zed-editor = {
        enable = true;
        extensions = [ "nix" ];
        userSettings = {
          base_keymap = "VSCode";
          ui_font_size = 17;
          buffer_font_size = 16;

          disable_ai = true;
          agent = {
            button = false;
            model_parameters = [ ];
          };

          tab_size = 2;

          format_on_save = "on";
          languages.Nix.language_servers = [
            "nixd"
            "!nil"
          ];
          lsp.nixd.settings = {
            nixpkgs.expr = "import (builtins.getFlake (builtins.toString ./.)).inputs.nixpkgs { }";
            formatting.command = [ "nixfmt" ];

            options = {
              flake-parts.expr = "(builtins.getFlake (builtins.toString ./.)).debug.options or { options = {}; }";
              per-system.expr = "(builtins.getFlake (builtins.toString ./.)).currentSystem.options or { options = {}; }";
              nixos.expr = "(builtins.elemAt (builtins.attrValues (builtins.getFlake (builtins.toString ./.)).nixosConfigurations) 0).options or { options = {}; }";
              home-manager.expr = "(builtins.elemAt (builtins.attrValues (builtins.getFlake (builtins.toString ./.)).homeConfigurations) 0).options or { options = {}; }";
            };
            diagnostic.suppress = [ "sema-extra-with" ];
          };
        };
      };
    };
}
