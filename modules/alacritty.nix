{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.alacritty ];
  };

  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.alacritty ];
  };

  modules.nixos.alacritty =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    {
      options.programs.alacritty.enable = (lib.mkEnableOption "alacritty") // {
        default = true;
      };

      config = lib.mkIf config.programs.alacritty.enable {
        environment.systemPackages = [ pkgs.alacritty ];
      };
    };

  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.alacritty ];
  };

  configurations.home."hana@shirayuri" = {
    imports = [ config.modules.home.alacritty ];
  };

  modules.home.alacritty = {
    programs.alacritty.enable = true;
  };

  modules.nixos.plasma =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.alacritty.enable {
        environment.plasma6.excludePackages = [ pkgs.kdePackages.konsole ];
      };
    };

  modules.nixos.xdg =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.alacritty.enable {
        xdg.terminal-exec.settings.default = [ "alacritty.desktop" ];
      };
    };
}
