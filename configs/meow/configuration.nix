{
  lib'',
  pkgs,
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
      "spotify"
    ])
  ];

  home.packages = with pkgs; [
    nixd
    nixfmt-rfc-style

    vesktop
    bitwarden
    (nixGL.wrap kdePackages.spectacle)
    spotify

    gamemode
    prismlauncher

    meow
    pyon

    openrgb
  ];

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

  xdg = {
    userDirs = {
      enable = true;
      pictures = "${homeDir}/Pictures";
    };

    configFile."vesktop/themes".source = "${midnight-theme}/share/themes/flavors";
  };
}
