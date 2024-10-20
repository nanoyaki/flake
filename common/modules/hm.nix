{
  lib,
  username,
  config,
  inputs,
  ...
}:

let
  inherit (lib) mkOption types mkIf;

  cfg = config.hm;
in

{
  options.hm = mkOption {
    type = types.attrs;
    default = { };
  };

  config.home-manager = mkIf (cfg != { }) {
    sharedModules = [
      inputs.catppuccin.homeManagerModules.catppuccin
    ];

    backupFileExtension = "home-bac";
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${username}.imports = [
      ../home.nix
      cfg
    ];
  };
}
