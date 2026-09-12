{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.noctalia ];
  };

  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.noctalia ];
  };

  modules.nixos.noctalia = {
    programs.noctalia.enable = true;
    programs.noctalia.recommendedServices.enable = true;
  };

  modules.home.noctalia = {
    programs.noctalia.enable = true;
  };

  modules.home.niri =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.noctalia.enable {
        programs.niri.settings.switch-events.lid-close.action.spawn = [
          "noctalia"
          "msg"
          "session"
          "lock"
        ];
      };
    };
}
