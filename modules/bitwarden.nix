{ config, ... }:

{
  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.bitwarden ];
  };

  configurations.home."hana@shirayuri" = {
    imports = [ config.modules.home.bitwarden ];
  };

  modules.home.bitwarden =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    let
      inherit (lib) mkEnableOption mkIf;
    in

    {
      options.programs.bitwarden.enable = mkEnableOption "bitwarden" // {
        default = true;
      };

      config = mkIf config.programs.bitwarden.enable {
        home.packages = [ pkgs.bitwarden-desktop ];
      };
    };
}
