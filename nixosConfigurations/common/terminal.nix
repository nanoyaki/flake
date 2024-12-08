{
  lib,
  pkgs,
  config,
  ...
}:

{
  hm.programs = {
    kitty = {
      enable = false;

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
}
