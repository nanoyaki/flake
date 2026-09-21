{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.shell ];
  };

  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.shell ];
  };

  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.shell ];
  };

  modules.nixos.shell =
    { lib, pkgs, ... }:

    {
      users.defaultUserShell = pkgs.bash;
      programs.bash.interactiveShellInit = ''
        if ! [ "$TERM" = "dumb" ] && [ -z "$BASH_EXECUTION_STRING" ]; then
          exec nu
        fi
      '';

      programs.nushell.enable = true;
      programs.nushell.plugins = with pkgs.nushellPlugins; [ formats ];

      environment.systemPackages = with pkgs; [
        ncdu
        jq
        btop
        lsd
        ripgrep
      ];

      programs.bat.enable = true;
      programs.starship.enable = true;
      programs.zoxide.enable = true;

      environment.shellAliases = {
        ls = "lsd";
        copy = "rsync -a --info=progress2 --info=name0";
        cd = "z";
      };

      environment.sessionVariables = {
        MANPAGER = "sh -c 'col -bx | ${lib.getExe pkgs.bat} -l man -p'";
        MANROFFOPT = "-c";
      };
    };

  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.shell ];
  };

  configurations.home."hana@kanokoyuri" = {
    imports = [ config.modules.home.shell ];
  };

  configurations.home."hana@shirayuri" = {
    imports = [ config.modules.home.shell ];
  };

  modules.home.shell =
    { pkgs, ... }:

    {
      programs = {
        zellij.enable = true;
        zellij.settings.pane_frames = false;
        zellij.settings.default_shell = "zsh";
        nushell.enable = true;
        nushell.plugins = with pkgs.nushellPlugins; [ formats ];
        starship.enable = true;
        btop.enable = true;
        lsd.enable = true;
        bat.enable = true;
        fastfetch.enable = true;
        ripgrep.enable = true;
        zoxide.enable = true;
      };
    };
}
