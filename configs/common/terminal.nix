{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption;

  cfg = config.modules.terminal;
in

{
  options.modules.terminal = {
    enableKitty = mkEnableOption "kitty";
  };

  config = {
    hm.programs = {
      kitty = {
        enable = cfg.enableKitty;

        font = {
          package = pkgs.cascadia-code;
          name = "Cascadia Mono";
          size = 13;
        };
      };

      alacritty = {
        enable = true;

        settings.terminal.shell = lib.mkIf config.hm.programs.zellij.enable {
          program = "zellij";
          args = [
            "attach"
            "default"
            "-c"
          ];
        };
      };
    };
  };
}
