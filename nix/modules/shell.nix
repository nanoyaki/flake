{
  flake.nixosModules.shell =
    { lib, pkgs, ... }:

    {
      users.defaultUserShell = pkgs.bash;
      programs.bash.enable = true;
      programs.bash.blesh.enable = true;

      environment.systemPackages = with pkgs; [
        alacritty
        unzip
        p7zip
        ncdu
        jq

        btop
        lsd
        ripgrep
      ];

      programs.bat.enable = true;
      programs.starship.enable = true;

      environment.shellAliases = {
        ls = "lsd";
        copy = "rsync -a --info=progress2 --info=name0";
      };

      environment.sessionVariables = {
        MANPAGER = "sh -c 'col -bx | ${lib.getExe pkgs.bat} -l man -p'";
        MANROFFOPT = "-c";
      };
    };

  flake.homeModules.shell =
    { config, ... }:

    {
      programs = {
        alacritty.enable = true;

        zellij.enable = true;
        zellij.settings.pane_frames = false;

        bash = {
          enable = true;
          enableCompletion = true;
          historyFile = "${config.xdg.dataHome}/bash/history";
          shellOptions = [
            "histappend"
            "extglob"
            "globstar"
            "checkjobs"
            "extglob"
          ];
        };

        starship.enable = true;

        btop.enable = true;
        lsd.enable = true;
        bat.enable = true;
        fastfetch.enable = true;
        ripgrep.enable = true;
      };
    };
}
