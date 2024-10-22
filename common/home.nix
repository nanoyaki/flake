{
  pkgs,
  config,
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
    home.username = username;
    home.homeDirectory = "/home/hana";
    home.stateVersion = "24.05";
    programs.home-manager.enable = true;

    home.file =
      let
        inherit (config.hm.lib.file) mkOutOfStoreSymlink;
      in
      {
        # Link several default directories to directories
        # from the shared-with-windows NTFS drive
        "Downloads".source = mkOutOfStoreSymlink "/mnt/1TB-SSD/Downloads";
        "Documents".source = mkOutOfStoreSymlink "/mnt/1TB-SSD/Documents";
        "Videos".source = mkOutOfStoreSymlink "/mnt/1TB-SSD/Videos";
        "Pictures".source = mkOutOfStoreSymlink "/mnt/1TB-SSD/Pictures";

        # The drives themselves
        "Windows".source = mkOutOfStoreSymlink "/mnt/Windows";
        "1TB-SSD".source = mkOutOfStoreSymlink "/mnt/1TB-SSD";
      };

    home.packages = with pkgs; [
      vesktop

      spotify

      obsidian

      bitwarden-desktop
    ];

    xdg.enable = true;
  };
}

# see common configuration.nix
# programs.neovim.coc = {
#   enable = true;
#   settings.languageserver.nix = {
#     command = "nil";
#     filetypes = ["nix"];
#     rootPatterns = ["flake.nix"];
#   };
# };

# link the configuration file in current directory to the specified location in home directory
# home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

# link all files in `./scripts` to `~/.config/i3/scripts`
# home.file.".config/i3/scripts" = {
#   source = ./scripts;
#   recursive = true;   # link recursively
#   executable = true;  # make all files executable
# };

# encode the file content in nix configuration file directly
# home.file.".xxx".text = ''
#     xxx
# '';

# Packages that should be installed to the user profile.
