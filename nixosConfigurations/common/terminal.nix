{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) mkIf mkOption types;

  cfg = config.modules.terminal;
in

{
  options.modules.terminal.zshAsDefaultShell = mkOption {
    type = types.bool;
    default = true;
  };

  config = {
    hm.programs = {
      zsh.enable = true;

      kitty = {
        enable = true;

        font = {
          package = pkgs.cascadia-code;
          name = "Cascadia Mono";
          size = 13;
        };
      };

      zellij = {
        enable = true;
        settings.pane_frames = false;
        settings.default_layout = "compact";
      };

      starship.enable = true;

      btop.enable = true;

      ssh =
        let
          identityFile = "${config.hm.home.homeDirectory}/.ssh/shirayuri-primary";
        in
        {
          enable = true;
          matchBlocks = {
            server = {
              user = "thelessone";
              hostname = "theless.one";
              inherit identityFile;
            };

            "github.com" = {
              user = "git";
              hostname = "github.com";
              inherit identityFile;
            };

            "codeberg.org" = {
              user = "git";
              hostname = "codeberg.org";
              inherit identityFile;
            };
          };
          extraConfig = ''
            IdentityFile ${identityFile}
          '';
        };

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

      lsd.enable = true;

      bat.enable = true;

      fastfetch.enable = true;

      ripgrep.enable = true;
    };

    users.defaultUserShell = mkIf cfg.zshAsDefaultShell pkgs.zsh;

    environment.pathsToLink = [ "/share/zsh" ];

    programs.zsh = {
      enable = true;
      ohMyZsh.enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        ll = "LANG=de_DE.UTF-8 ls -latr --color=auto";
        copy = "rsync -a --info=progress2 --info=name0";
        nix-conf = "$EDITOR $FLAKE_DIR";
        nix-op = "$BROWSER \"https://search.nixos.org/options?channel=unstable\"";
        nix-pac = "$BROWSER \"https://search.nixos.org/packages?channel=unstable\"";
        nix-hom = "$BROWSER \"https://home-manager-options.extranix.com/\"";
        rb = "sudo nixos-rebuild switch --flake $FLAKE_DIR";
      };
      histSize = 10000;
    };

    environment.systemPackages = with pkgs; [
      nvtopPackages.amd
      gnupg
    ];

    environment.sessionVariables = {
      MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
      MANROFFOPT = "-c";
    };
  };
}
