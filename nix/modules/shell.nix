{
  flake.nixosModules.shell =
    { lib, pkgs, ... }:

    {
      environment.pathsToLink = [ "/share/zsh" ];
      users.defaultUserShell = pkgs.zsh;
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        enableBashCompletion = true;
        autosuggestions.enable = true;
        syntaxHighlighting = {
          enable = true;
          highlighters = [
            "main"
            "pattern"
          ];
          patterns."rm -rf" = "fg=white,bold,bg=red";
        };

        histSize = 10000;
        histFile = "$XDG_STATE_HOME/.zsh_history";

        interactiveShellInit = ''
          bindkey -e
          bindkey "^[[H"    beginning-of-line
          bindkey "^[[F"    end-of-line
          bindkey "^[[3~"   delete-char
          bindkey "^[[1;5C" forward-word
          bindkey "^[[1;5D" backward-word
          bindkey "^[[3;5~" kill-word
          bindkey "^H"      backward-kill-word
        '';
      };

      environment.systemPackages = with pkgs; [
        alacritty
        unzip
        p7zip
        ncdu
        jq

        btop
        lsd
        ripgrep
      ];

      programs.bat.enable = true;
      programs.starship.enable = true;
      programs.zoxide.enable = true;

      environment.shellAliases = {
        ls = "lsd";
        copy = "rsync -a --info=progress2 --info=name0";
        cd = "z";
      };

      environment.sessionVariables = {
        MANPAGER = "sh -c 'col -bx | ${lib.getExe pkgs.bat} -l man -p'";
        MANROFFOPT = "-c";
      };
    };

  flake.homeModules.shell =
    { pkgs, config, ... }:

    {
      home.packages = with pkgs; [ wl-clipboard ];

      programs = {
        alacritty.enable = true;
        alacritty.package = null;

        zellij.enable = true;
        zellij.settings.pane_frames = false;
        zellij.settings.default_shell = "zsh";

        zsh = {
          enable = true;
          autocd = true;
          enableCompletion = true;
          autosuggestion.enable = true;
          syntaxHighlighting = {
            enable = true;
            highlighters = [
              "main"
              "pattern"
            ];
            patterns."rm -rf" = "fg=white,bold,bg=red";
          };
          defaultKeymap = "emacs";
          initContent = ''
            bindkey "^[[H"    beginning-of-line
            bindkey "^[[F"    end-of-line
            bindkey "^[[3~"   delete-char
            bindkey "^[[1;5C" forward-word
            bindkey "^[[1;5D" backward-word
            bindkey "^[[3;5~" kill-word
            bindkey "^H"      backward-kill-word
          '';
          dotDir = "${config.xdg.configHome}/zsh";
        };

        starship.enable = true;

        btop.enable = true;
        lsd.enable = true;
        bat.enable = true;
        fastfetch.enable = true;
        ripgrep.enable = true;
        zoxide.enable = true;
      };
    };
}
