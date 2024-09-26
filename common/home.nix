{ pkgs, ... }:
{
  home.username = "hana";
  home.homeDirectory = "/home/hana";

  # Theming
  catppuccin.enable = true;
  catppuccin.flavor = "macchiato";
  catppuccin.accent = "pink";

  # Program theming
  # gtk = {
  #   enable = true;
  #   catppuccin.icon = {
  #     enable = true;
  #     accent = "pink";
  #     flavor = "macchiato";
  #   };
  #   catppuccin.enable = true;
  #   catppuccin.gnomeShellTheme = true;
  #   catppuccin.size = "standard";
  #   gtk4.extraConfig = {
  #     gtk-application-prefer-dark-theme = true;
  #   };
  #   gtk3.extraConfig = {
  #     gtk-application-prefer-dark-theme = true;
  #   };
  # };
  programs.btop = {
    enable = true;
    catppuccin.enable = true;
  };
  qt = {
    enable = true;
    style.catppuccin.enable = true;
    style.name = "kvantum";
    platformTheme.name = "kvantum";
  };
  programs.zsh = {
    enable = true;
    syntaxHighlighting.catppuccin.enable = true;
    oh-my-zsh = {
      enable = true;
    };
  };
  programs.starship = {
    enable = true;
    catppuccin.enable = true;
  };
  programs.alacritty = {
    enable = true;
    catppuccin.enable = true;
  };
  programs.mpv = {
    enable = true;
    catppuccin.enable = true;
  };
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
  };

  services.unison = {
    enable = true;
    pairs.sync = {
        roots = [
          "/home/hana/Sync"
          "ssh://sync@theless.one//var/lib/sync/hana"
        ];
      };
    };
  };

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # Communication
    vesktop
    # (discord.override {
    #   withOpenASAR = true;
    #   withVencord = false;
    # })

    # Media
    spotify
    yt-dlp

    # Games
    prismlauncher

    # Editors
    obsidian

    # Password manager
    bitwarden-desktop

    # Terminal
    fastfetch
    nvtopPackages.amd

    # eID
    ausweisapp

    # Theming
    (catppuccin.override {
      accent = "pink";
      variant = "macchiato";
    })
  ];

  xdg.enable = true;

  programs.git = {
    userName = "nanoyaki";
    userEmail = "hanakretzer@gmail.com";
    delta.catppuccin.enable = true;
  };

  home.file.".ssh/config".text = ''
    Host server
      User thelessone
      HostName theless.one
  '';

  # see common configuration.nix
  # programs.neovim.coc = {
  #   enable = true;
  #   settings.languageserver.nix = {
  #     command = "nil";
  #     filetypes = ["nix"];
  #     rootPatterns = ["flake.nix"];
  #   };
  # };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
