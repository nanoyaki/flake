{
  config,
  pkgs,
  ...
}: {
  home.username = "hana";
  home.homeDirectory = "/home/hana";

  # Theming
  catppuccin.enable = true;
  catppuccin.flavor = "macchiato";
  catppuccin.accent = "pink";

  # Program theming
  programs.kitty.catppuccin.enable = true;
  programs.mpv.catppuccin.enable = true;
  gtk = {
    catppuccin.icon = {
      enable = true;
      accent = "pink";
      flavor = "macchiato";
    };
    catppuccin.size = "standard";
    enable = true;
  };
  programs.btop = {
    enable = true;
    catppuccin.enable = true;
  };
  i18n.inputMethod.fcitx5.catppuccin.enable = true;
  programs.git.delta.catppuccin.enable = true;
  programs.zsh.syntaxHighlighting.catppuccin.enable = true;
  qt.style.catppuccin.enable = true;

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
    mpv
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

    # Theming
    catppuccin-cursors.macchiatoPink
    (catppuccin.override {
      accent = "pink";
      variant = "macchiato";
    })
    (catppuccin-kde.override {
      flavour = ["macchiato"];
      accents = ["pink"];
    })
  ];

  xdg.enable = true;

  programs.git = {
    userName = "nanoyaki";
    userEmail = "hanakretzer@gmail.com";
  };

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
