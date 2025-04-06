{
  pkgs,
  username,
  config,
  ...
}:

let
  identityFile = config.sec."private_keys/id_nadesiko".path;

  midnight-theme = pkgs.midnight-theme.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [ ../common/optional/vencord-icon.patch ];
  });
in

{
  programs.home-manager.enable = true;
  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    packages = with pkgs; [
      nix
      nixd
      nixfmt-rfc-style

      vesktop
      wlx-overlay-s
    ];

    stateVersion = "25.05";
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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
  };

  xdg.enable = true;
  xdg.configFile."vesktop/themes".source = "${midnight-theme}/share/themes/flavors";
}
