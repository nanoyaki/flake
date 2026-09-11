{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.zed ];
  };

  modules.nixos.zed =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    {
      options.programs.zed-editor.enable = (lib.mkEnableOption "the zed editor") // {
        default = true;
      };

      config = lib.mkIf config.programs.zed-editor.enable {
        environment.systemPackages = with pkgs; [
          zed-editor
          # This should be dev shell stuff
          vscode-json-languageserver
        ];

        environment.sessionVariables.EDITOR = lib.getExe pkgs.zed-editor;
      };
    };

  modules.nixos.nix =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    {
      config = lib.mkIf config.programs.zed-editor.enable {
        environment.systemPackages = [
          # This should be dev shell stuff
          pkgs.nixd
        ];

        environment.sessionVariables.GIT_EDITOR = "${lib.getExe pkgs.zed-editor} --wait";
      };
    };

  modules.nixos.sops =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    {
      config = lib.mkIf config.programs.zed-editor.enable {
        environment.sessionVariables.SOPS_EDITOR = "${lib.getExe pkgs.zed-editor} --wait";
      };
    };

  modules.home.zed = {
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
            nixos.expr = "let flake = builtins.getFlake (builtins.toString ./.); in builtins.head (builtins.attrValues flake.nixosConfigurations)";
            home-manager.expr = "let flake = builtins.getFlake (builtins.toString ./.); in builtins.head (builtins.attrValues flake.homeConfigurations)";
          };
          diagnostic.suppress = [ "sema-extra-with" ];
        };

        profiles.performance.lsp.nixd.settings.options = {
          nixos.expr = "let flake = builtins.getFlake (builtins.toString ./.); inherit (flake.inputs.nixpkgs) lib; in builtins.foldl' (acc: cfg: lib.recursiveUpdate acc cfg.options) { } (builtins.attrValues flake.nixosConfigurations)";
          home-manager.expr = "let flake = builtins.getFlake (builtins.toString ./.); inherit (flake.inputs.nixpkgs) lib; in builtins.foldl' (acc: cfg: lib.recursiveUpdate acc cfg.options) { } (builtins.attrValues flake.homeConfigurations)";
        };
      };
    };
  };
}
