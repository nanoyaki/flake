{ lib, pkgs, ... }:

{
  # Shell
  programs = {
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

      enableCompletion = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
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

    lsd = {
      enable = true;
      enableAliases = true;
    };

    btop.enable = true;
    bat.enable = true;
    fastfetch.enable = true;
    ripgrep.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };
  };
}
