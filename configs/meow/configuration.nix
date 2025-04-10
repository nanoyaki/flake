{
  lib,
  lib'',
  pkgs,
  username,
  config,
  inputs,
  ...
}:

let
  identityFile = config.sec."private_keys/id_nadesiko".path;

  midnight-theme = pkgs.midnight-theme.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [ ../common/optional/vencord-icon.patch ];
  });

  homeDir = config.home.homeDirectory;

  inherit (config.lib) nixGL;
in

{
  nixpkgs.overlays = [
    inputs.prismlauncher.overlays.default
    (_: prev: {
      prismlauncher = prev.prismlauncher.override {
        jdks = with prev; [
          graalvm-ce
          zulu8
          zulu17
          zulu
        ];
      };
    })
    (lib''.nixGlOverlay [
      "vesktop"
      "prismlauncher"
    ])
  ];

  targets.genericLinux.enable = true;

  programs.home-manager.enable = true;
  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    packages = with pkgs; [
      nix
      nixd
      nixfmt-rfc-style

      vesktop
      bitwarden
      (nixGL.wrap kdePackages.spectacle)

      gamemode
      prismlauncher

      meow
      pyon

      openrgb
      vermeer-undervolt
    ];

    stateVersion = "25.05";

    shell.enableShellIntegration = true;
    shellAliases.rb = "home-manager switch --flake $FLAKE_DIR";
    sessionVariables.FLAKE_DIR = "$HOME/flake";
  };

  programs.ssh = {
    enable = true;

    matchBlocks.git = {
      user = "git";
      host = "github.com codeberg.org gitlab.com git.theless.one";
      inherit identityFile;
    };

    extraConfig = ''
      IdentityFile ${identityFile}
      AddKeysToAgent yes
    '';
  };

  programs.git = {
    enable = true;
    userName = "Hana Kretzer";
    userEmail = "hanakretzer@gmail.com";
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
  };

  programs.mpv = {
    enable = true;
    package = config.lib.nixGL.wrap (
      pkgs.mpv-unwrapped.wrapper {
        scripts = with pkgs.mpvScripts; [
          sponsorblock
          thumbfast
          modernx
          mpvacious
          mpv-discord
          mpv-subtitle-lines
          mpv-playlistmanager
          mpv-cheatsheet
        ];

        mpv = pkgs.mpv-unwrapped;
      }
    );

    config = {
      osc = "no";
      volume = 20;
    };
  };

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

  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps.enable = true;
    autostart.enable = true;

    userDirs = {
      enable = true;
      pictures = "${homeDir}/Pictures";
    };

    configFile."vesktop/themes".source = "${midnight-theme}/share/themes/flavors";
  };
}
