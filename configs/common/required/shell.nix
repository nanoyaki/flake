{
  pkgs,
  config,
  ...
}:

{
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    enableBashCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;

    interactiveShellInit = ''
      bindkey "^[[H"    beginning-of-line
      bindkey "^[[F"    end-of-line
      bindkey "^[[3~"   delete-char
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      bindkey "^[[3;5~" kill-word
      bindkey "^H"      backward-kill-word
    '';

    histSize = 10000;
  };

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "rb";
      runtimeInputs = with pkgs; [
        nix-fast-build
      ];
      text = ''
        set -e

        if [[ $EUID -ne 0 ]]; then
          echo "Script requires root priviledges."
          exit 1
        fi

        nix-fast-build --eval-workers 4 --out-link result \
          -f ${config.nanoflake.nix.flakeDir}#nixosConfigurations."$(hostname)".config.system.build.toplevel

        echo "Deleting home-manager backups..."
        find ~ -name "*.home-bac" -exec rm -r {} +

        echo "Running switch-to-configuration switch..."
        ./result-/bin/switch-to-configuration switch

        echo "Adding system profile..."
        NEWEST_GEN="$(nix-env --profile /nix/var/nix/profiles/system --list-generations | awk '{ print $1 }' | tail -n -1)";
        BUILT_GEN="$((NEWEST_GEN + 1))"

        sudo ln -s "$(readlink -f ./result-)" /nix/var/nix/profiles/system-$BUILT_GEN-link

        echo "Switching system profile..."
        nix-env --profile /nix/var/nix/profiles/system --switch-generation $BUILT_GEN

        echo "Deleting result link..."
        rm -rf "./result-"

        echo "Done."
      '';
    })
  ];
}
