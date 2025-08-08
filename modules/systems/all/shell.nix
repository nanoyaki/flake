{
  lib',
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib'.options) mkTrueOption;

  cfg = config.config'.shell;
in

{
  options.config'.shell.enableComfortUtils = mkTrueOption;

  config = {
    users.defaultUserShell = pkgs.zsh;
    programs.zsh = {
      enable = true;

      enableCompletion = true;
      enableBashCompletion = true;
      syntaxHighlighting.enable = true;
      autosuggestions.enable = true;

      interactiveShellInit = ''
        bindkey "^[[H"    beginning-of-line
        bindkey "^[[F"    end-of-line
        bindkey "^[[3~"   delete-char
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
        bindkey "^[[3;5~" kill-word
        bindkey "^H"      backward-kill-word
      '';

      histSize = 10000;
    };

    environment = mkIf cfg.enableComfortUtils {
      shellAliases.copy = "rsync -a --info=progress2 --info=name0";
      systemPackages = with pkgs; [
        prefetch
        unrar
        unzip
        p7zip
        ncdu
        jq
      ];
      sessionVariables = {
        MANPAGER = "sh -c 'col -bx | ${lib.getExe pkgs.bat} -l man -p'";
        MANROFFOPT = "-c";
      };
    };

    hms = [
      {
        programs = mkIf cfg.enableComfortUtils {
          zsh.enable = true;

          zellij = {
            enable = true;

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
      }
    ];
  };
}
