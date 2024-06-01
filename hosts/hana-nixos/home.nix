{
  config,
  pkgs,
  ...
}: {
  imports = [
    # ../../common/modules/home/gamemode/gamemode.nix
  ];
  # dirty workaround since im dumb
  # home.file.".config/mongodb/" = {
  #   source = ../../common/modules/mongodb/configs;
  #   recursive = true;
  # };

  home.packages = with pkgs; [
    # Games
    protonup
    bottles
    parsec-bin
    cartridges
    lutris-unwrapped
  ];
}
