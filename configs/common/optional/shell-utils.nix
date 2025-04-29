{ lib, pkgs, ... }:

{
  hm.programs = {
    zsh = {
      enable = true;
      initContent = ''
        ${lib.getExe pkgs.meow}
      '';
    };

    zellij = {
      enable = true;

      enableBashIntegration = lib.mkDefault false;
      enableZshIntegration = lib.mkDefault false;
      enableFishIntegration = lib.mkDefault false;

      settings = {
        pane_frames = false;
        default_layout = "compact";
        session_serialization = false;
      };
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    lsd.enable = true;
    btop.enable = true;
    bat.enable = true;
    fastfetch.enable = true;
    ripgrep.enable = true;
  };

  programs.zsh.shellAliases.copy = "rsync -a --info=progress2 --info=name0";

  environment.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | ${lib.getExe pkgs.bat} -l man -p'";
    MANROFFOPT = "-c";
  };
}
