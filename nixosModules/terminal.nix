{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.terminal;
in
{
  options.modules.terminal.zshAsDefaultShell = mkOption {
    type = types.bool;
    default = true;
    description = "Use zsh as the default shell.";
  };

  config = {
    hm.programs = {
      zsh.enable = true;

      alacritty = {
        enable = true;
        settings.terminal.shell.program = "zellij";
      };

      zellij = {
        enable = true;
        enableZshIntegration = true;
      };

      starship.enable = true;

      btop.enable = true;

      ssh = {
        enable = true;
        matchBlocks.server = {
          user = "thelessone";
          hostname = "theless.one";
          identityFile = "${config.hm.home.homeDirectory}/.ssh/shirayuri-primary";
        };
      };
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
      };
      histSize = 10000;
    };

    console.keyMap = "de";

    environment.systemPackages = with pkgs; [
      fastfetch
      nvtopPackages.amd

      yt-dlp

      gnupg
    ];
  };
}
