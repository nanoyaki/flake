{
  lib',
  lib,
  config,
  ...
}:

let
  inherit (lib'.options)
    mkListOf
    mkStrOption
    mkDefault
    mkEither
    ;

  cfg = config.config'.localization;

  characterSet = builtins.elemAt (lib.strings.splitString "." cfg.locale) 1;
  posixLocalePredicate = lang: (builtins.match "^[a-z]{2}_[A-Z]{2}$" lang) != null;
in

{
  options.config'.localization = {
    # The IANA timezone of the system
    timezone = mkDefault "Europe/Berlin" mkStrOption;
    # The language preference order to set for messages
    language = mkDefault "de_DE" (mkEither mkStrOption (mkListOf mkStrOption));
    # The locale for everything but messages
    locale = mkDefault "de_DE.UTF-8" mkStrOption;
    # Extra locales to add to {option}`i18n.extraLocales`
    extraLocales = mkListOf mkStrOption;
  };

  config = {
    assertions = [
      {
        assertion =
          if builtins.isString cfg.language then
            posixLocalePredicate cfg.language
          else
            lib.lists.any posixLocalePredicate cfg.language;
        message = "The config'.localization.language option must contain the country code like in the posix locale";
      }
    ];

    time.timeZone = cfg.timezone;

    i18n = {
      defaultLocale = cfg.locale;

      extraLocaleSettings = rec {
        LANGUAGE =
          if builtins.isString cfg.language then
            "${cfg.language}.${characterSet}"
          else
            "${lib.lists.findFirst posixLocalePredicate "en_US" cfg.language}.${characterSet}";
        LC_MESSAGES = LANGUAGE;
      }
      // builtins.listToAttrs (
        builtins.map (lcKey: lib.nameValuePair lcKey cfg.locale) [
          "LC_ADDRESS"
          "LC_IDENTIFICATION"
          "LC_MEASUREMENT"
          "LC_MONETARY"
          "LC_NAME"
          "LC_NUMERIC"
          "LC_PAPER"
          "LC_TELEPHONE"
          "LC_TIME"
          "LC_COLLATE"
          "LC_CTYPE"
        ]
      );

      inherit (cfg) extraLocales;
    };

    environment.sessionVariables = config.i18n.extraLocaleSettings // {
      LC_ALL = "";
      LANGUAGE = lib.mkForce (
        if builtins.isString cfg.language then
          cfg.language
        else
          lib.strings.concatStrings (lib.strings.intersperse ":" cfg.language)
      );
    };
  };
}
