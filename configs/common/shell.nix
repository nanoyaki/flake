{
  lib,
  pkgs,
  ...
}:

{
  hm.programs = {
    zsh = {
      enable = true;
      initExtra = ''
        bindkey "^[[H"    beginning-of-line
        bindkey "^[[F"    end-of-line
        bindkey "^[[3~"   delete-char
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
        bindkey "^[[3;5~" kill-word
        bindkey "^H"      backward-kill-word

        ${lib.getExe pkgs.meow}
      '';
    };

    zellij = {
      enable = true;

      settings = {
        pane_frames = false;
        default_layout = "compact";
      };
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    btop.enable = true;

    tealdeer = {
      enable = true;

      settings = {
        display = {
          compact = false;
          use_pager = true;
        };

        updates.auto_update = true;
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    lsd = {
      enable = true;
      enableAliases = true;
    };

    bat.enable = true;

    fastfetch.enable = true;

    ripgrep.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      copy = "rsync -a --info=progress2 --info=name0";
      rb = "sudo nixos-rebuild switch --flake $FLAKE_DIR";
      cat = "${lib.getExe pkgs.bat}";

      nix-conf = "$EDITOR $FLAKE_DIR";
      nix-op = "man configuration.nix";
      nix-hom = "man home-configuration.nix";
    };

    histSize = 10000;
  };

  environment = {
    pathsToLink = [ "/share/zsh" ];

    sessionVariables = {
      MANPAGER = "sh -c 'col -bx | ${lib.getExe pkgs.bat} -l man -p'";
      MANROFFOPT = "-c";
    };

    systemPackages = [ pkgs.gnupg ];
  };
}
