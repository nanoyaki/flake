{
  pkgs,
  ...
}:

{
  hm.programs = {
    zsh.enable = true;

    zellij = {
      enable = true;
      settings.pane_frames = false;
      settings.default_layout = "compact";
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
    ohMyZsh.enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      copy = "rsync -a --info=progress2 --info=name0";
      rb = "sudo nixos-rebuild switch --flake $FLAKE_DIR";
      cat = "bat";

      nix-conf = "$EDITOR $FLAKE_DIR";
      nix-op = "$BROWSER \"https://search.nixos.org/options?channel=unstable\"";
      nix-pac = "$BROWSER \"https://search.nixos.org/packages?channel=unstable\"";
      nix-hom = "$BROWSER \"https://home-manager-options.extranix.com/\"";
    };
    histSize = 10000;
  };

  environment.pathsToLink = [ "/share/zsh" ];

  environment.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
    MANROFFOPT = "-c";
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.amd
    gnupg
  ];
}
