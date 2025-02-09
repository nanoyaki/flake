{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) mkOption types;

  cfg = config.nanoflake.homePackages;
in

{
  options.nanoflake.homePackages = mkOption {
    type = types.listOf types.package;
    default = [ ];
    example = lib.literalExpression ''with pkgs; [ anki ]'';
    description = "A list of extra packages to install to the main user's home";
  };

  config.hm.home.packages =
    (with pkgs; [
      (vesktop.override {
        withMiddleClickScroll = true;
        electron = pkgs.electron_33;
      })
      bitwarden-desktop
    ])
    ++ cfg;
}
