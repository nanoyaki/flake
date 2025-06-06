{ lib, config, ... }:

let
  inherit (lib) mkOption types;

  cfg = config.nanoflake.localization;

  characterSet = builtins.elemAt (lib.strings.splitString "." cfg.locale) 1;
  posixLocalePredicate = lang: (builtins.match "^[a-z]{2}_[A-Z]{2}$" lang) != null;
in

{
  options.nanoflake.localization = {
    timezone = mkOption {
      type = types.str;
      default = "Europe/Berlin";
      example = "Europe/London";
      description = "The IANA timezone of the system";
    };

    language = mkOption {
      type = types.either types.str (types.listOf types.str);
      default = "de_DE";
      example = lib.literalExpression ''[ "de_DE" "en" ]'';
      description = ''
        The language preference order to set for messages.
        Sets {option}`i18n.extraLocaleSettings.LANGUAGE` and {option}`i18n.extraLocaleSettings.LC_MESSAGES`
      '';
    };

    locale = mkOption {
      type = types.str;
      default = "de_DE.UTF-8";
      example = "en_GB.UTF-8";
      description = ''
        The locale for everything but messages.
      '';
    };

    extraLocales = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = lib.literalExpression ''[ "en_GB.UTF-8/UTF-8" ]'';
      description = "Extra locales to add to {option}`i18n.extraLocales`";
    };
  };

  config = {
    assertions = [
      {
        assertion =
          if builtins.isString cfg.language then
            posixLocalePredicate cfg.language
          else
            lib.lists.any posixLocalePredicate cfg.language;
        message = "The nanoflake.localization.language option must contain the country code like in the posix locale";
      }
    ];

    time.timeZone = cfg.timezone;

    i18n = {
      defaultLocale = cfg.locale;

      extraLocaleSettings =
        rec {
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
