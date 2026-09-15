{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.bitwarden ];
  };

  modules.nixos.bitwarden =
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
        environment.systemPackages = with pkgs; [
          bitwarden-desktop
          bitwarden-cli
        ];
      };
    };

  configurations.home."hana@himawari" = {
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
        home.packages = with pkgs; [
          bitwarden-desktop
          bitwarden-cli
        ];
      };
    };
}
