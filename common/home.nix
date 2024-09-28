{ pkgs, ... }:
{
  home.username = "hana";
  home.homeDirectory = "/home/hana";
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  # Theming
  catppuccin.enable = true;
  catppuccin.flavor = "macchiato";
  catppuccin.accent = "pink";

  qt = {
    enable = true;
    style.catppuccin.enable = true;
    style.name = "kvantum";
    platformTheme.name = "kvantum";
  };

  programs.mpv = {
    enable = true;
    catppuccin.enable = true;
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

  # Terminal
  programs.alacritty = {
    enable = true;
    catppuccin.enable = true;
    settings.shell = {
      program = "zellij";
      args = [
        "-l"
        "welcome"
      ];
    };
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

  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.btop = {
    enable = true;
    catppuccin.enable = true;
  };

  programs.git = {
    enable = true;
    userName = "nanoyaki";
    userEmail = "hanakretzer@gmail.com";
    delta.catppuccin.enable = true;
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      server = {
        user = "thelessone";
        hostname = "theless.one";
        localForwards = [
          {
            bind.port = 2333;
            host.address = "localhost";
            host.port = 2333;
          }
        ];
      };
    };
  };

  xdg.enable = true;

  home.packages = with pkgs; [
    # Communication
    vesktop
    # (discord.override {
    #   withOpenASAR = true;
    #   withVencord = false;
    # })

    # Media
    spotify

    # Editors
    obsidian

    # Password manager
    bitwarden-desktop
  ];
}

# see common configuration.nix
# programs.neovim.coc = {
#   enable = true;
#   settings.languageserver.nix = {
#     command = "nil";
#     filetypes = ["nix"];
#     rootPatterns = ["flake.nix"];
#   };
# };

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
