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
  options.modules.terminal = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable custom terminal options.";
    };

    zshAsDefaultShell = mkOption {
      type = types.bool;
      default = true;
      description = "Use zsh as the default shell.";
    };

    withOpenssl = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable openssl for cryptography.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Terminal
      (mkIf cfg.withOpenssl openssl)
      kitty
    ];

    # Zsh
    users.defaultUserShell = mkIf cfg.zshAsDefaultShell pkgs.zsh;
    environment.pathsToLink = [ "/share/zsh" ];
    programs.zsh = {
      enable = true;
      ohMyZsh.enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      # promptInit = mkIf cfg.withP10k "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme LANGUAGE=${config.i18n.defaultLocale}";

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

    # Configure console keymap
    console.keyMap = "de";
  };
}
