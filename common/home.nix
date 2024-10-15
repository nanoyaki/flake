{ pkgs, ... }:

let
  username = "hana";

  catppuccin = {
    enable = true;
    flavor = "macchiato";
  };
in

{
  home.username = username;
  home.homeDirectory = "/home/hana";
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  # Theming
  catppuccin = {
    inherit (catppuccin) enable flavor;
    accent = "pink";
  };

  qt = {
    enable = true;
    style = {
      name = "kvantum";
      inherit catppuccin;
    };
    platformTheme.name = "kvantum";
  };

  programs.mpv = {
    enable = true;
    inherit catppuccin;
  };

  services.unison = {
    enable = true;
    package = pkgs.unison;
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
    settings.shell.program = "zellij";
    inherit catppuccin;
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting = {
      inherit catppuccin;
    };
  };

  programs.starship = {
    enable = true;
    inherit catppuccin;
  };

  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    inherit catppuccin;
  };

  programs.btop = {
    enable = true;
    inherit catppuccin;
  };

  programs.git = {
    enable = true;
    userName = "nanoyaki";
    userEmail = "hanakretzer@gmail.com";
    delta = {
      inherit catppuccin;
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks.server = {
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
