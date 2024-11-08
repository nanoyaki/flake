{
  lib,
  pkgs,
  username,
  inputs,
  ...
}:

let
  inherit (inputs) home-manager catppuccin;
in

{
  imports = [
    home-manager.nixosModules.home-manager
    (lib.modules.mkAliasOptionModule [ "hm" ] [
      "home-manager"
      "users"
      username
    ])
  ];

  home-manager = {
    sharedModules = [
      catppuccin.homeManagerModules.catppuccin
    ];

    backupFileExtension = "home-bac";
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  hm = {
    home = {
      inherit username;

      homeDirectory = "/home/${username}";
      stateVersion = "24.11";

      packages = with pkgs; [
        vesktop

        obsidian

        bitwarden-desktop
      ];
    };

    programs.home-manager.enable = true;
    xdg.enable = true;
  };
}
