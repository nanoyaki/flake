{
  lib,
  pkgs,
  ...
}:

{
  nanoflake.localization = {
    timezone = "Europe/Vienna";
    language = "de_AT";
    locale = "de_AT.UTF-8";
  };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "update" ''
      find ~ -name "*home-bac" | xargs rm
      pushd $FLAKE_DIR
      ${lib.getExe pkgs.git} pull
      sudo nixos-rebuild switch --flake $FLAKE_DIR
      popd
    '')
  ];

  system.stateVersion = "25.05";
  hm.home.stateVersion = "25.05";
}
