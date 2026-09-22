{ config, ... }:

{
  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.thunderbird ];
  };

  configurations.home."hana@shirayuri" = {
    imports = [ config.modules.home.thunderbird ];
  };

  modules.home.thunderbird = {
    programs.thunderbird.enable = true;
  };

  modules.home.xdg =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.thunderbird.enable {
        xdg.mimeApps.defaultApplications = {
          "message/rfc822" = "thunderbird.desktop";
          "x-scheme-handler/mailto" = "thunderbird.desktop";
          "x-scheme-handler/mid" = "thunderbird.desktop";
          "application/x-extension-eml" = "thunderbird.desktop";
          "text/calendar" = "thunderbird.desktop";
          "application/ics" = "thunderbird.desktop";
          "x-scheme-handler/webcal" = "thunderbird.desktop";
        };
      };
    };
}
