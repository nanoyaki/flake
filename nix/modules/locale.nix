{
  flake.nixosModules.locale =
    let
      german = "de_DE.UTF-8";
    in

    {
      console.keyMap = "de";
      time.timeZone = "Europe/Berlin";

      i18n.defaultLocale = "en_GB.UTF-8";
      i18n.extraLocales = [ "${german}/UTF-8" ];
      i18n.extraLocaleSettings = {
        LC_MESSAGES = "en_GB.UTF-8";
        LC_ADDRESS = german;
        LC_IDENTIFICATION = german;
        LC_MEASUREMENT = german;
        LC_MONETARY = german;
        LC_NAME = german;
        LC_NUMERIC = german;
        LC_PAPER = german;
        LC_TELEPHONE = german;
        LC_TIME = german;
        LC_COLLATE = german;
        LC_CTYPE = german;
      };
    };
}
