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
    _:

    {
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
        };
      };
    };
}
