{ lib, config, ... }:

{
  hm.programs.alacritty = {
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
}
