{
  hm.programs.alacritty = {
    enable = true;

    settings.terminal.shell = {
      program = "zellij";
      args = [
        "-l"
        "welcome"
      ];
    };
  };
}
