{ config, pkgs, ... }:

{
  home.username = "hana";
  home.homeDirectory = "/home/hana";

  # Theming
  catppuccin.flavour = "frappe";

  # Program theming
  programs.kitty.catppuccin.enable = true;
  programs.mpv.catppuccin.enable = true;
  gtk = {
    # causes home-manager to crash for some reason
    # enable = true;
    catppuccin = {
      enable = true;
      flavour = "frappe";
      accent = "pink";
      size = "standard";
      tweaks = [ "normal" ];
    };
    iconTheme.package = pkgs.catppuccin-papirus-folders.override {
      variant = "frappe";
      accent = "pink";
    };
  };
  i18n.inputMethod.fcitx5.catppuccin.enable = true;
  programs.btop = {
    enable = true;
    catppuccin.enable = true;
  };
  programs.zsh.syntaxHighlighting.catppuccin.enable = true;

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

  # home.file.".config/vesktop/settings/settings.json".text = '''';

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # Communication
    vesktop
    thunderbird
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })

    # Media
    mpv
    spotify

    # Games 
    lutris-unwrapped
    osu-lazer-bin
    parsec-bin
    cartridges

    # Editors
    obsidian

    # Password manager
    bitwarden-desktop

    # Terminal
    kitty
    fastfetch

    # Theming
    papirus-icon-theme
    catppuccin-cursors.frappePink
    (catppuccin.override {
      accent = "pink";
      variant = "frappe";
    })
    (catppuccin-kde.override {
      flavour = [ "frappe" ];
      accents = [ "pink" ];
    })
  ];

  xdg.enable = true;

  programs.git = {
    userName = "Hana Kretzer";
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