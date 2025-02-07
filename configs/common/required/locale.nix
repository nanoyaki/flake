{ lib, config, ... }:

let
  inherit (lib) mkOption types;

  cfg = config.nanoflake.localization;

  languagePreference =
    if builtins.isString cfg.language then cfg.language else lib.strings.intersperse ":" cfg.language;
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
        Sets all LC_* variables apart from LC_ALL
      '';
    };

    extraLocales = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = lib.literalExpression ''[ "en_GB.UTF-8/UTF-8" ]'';
      description = "Extra locales to add to {option}`i18n.supportedLocales`";
    };
  };

  config = {
    time.timeZone = cfg.timezone;

    i18n = {
      defaultLocale = cfg.locale;

      extraLocaleSettings =
        {
          LANGUAGE = languagePreference;
          LC_MESSAGES = languagePreference;
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
          ]
        );

      supportedLocales = cfg.extraLocales;
    };
  };
}
