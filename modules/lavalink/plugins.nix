{ lib, pkgs }:

let
  inherit (lib) types mkOption;

  format = pkgs.formats.yaml { };
in

{
  options = {
    dependency = mkOption {
      type = types.str;
      example = "dev.lavalink.youtube:youtube-plugin:1.8.0";
      description = ''
        The coordinates of the plugin.
      '';
    };

    repository = mkOption {
      type = types.str;
      example = "https://maven.example.com/releases";
      default = "https://maven.lavalink.dev/releases";
      description = ''
        The plugin repository. Defaults to the lavalink releases repository.

        To use the snapshots repository, use <https://maven.lavalink.dev/snapshots> instead
      '';
    };

    hash = mkOption {
      type = types.str;
      example = lib.fakeHash;
      description = ''
        The hash of the plugin.
      '';
    };

    configName = mkOption {
      type = types.nullOr types.str;
      example = "youtube";
      default = null;
      description = ''
        The name of the plugin to use as the key for the plugin configuration.
      '';
    };

    extraConfig = mkOption {
      type = types.submodule { freeformType = format.type; };
      default = { };
      description = ''
        The configuration for the plugin.

        The {option}`services.lavalink.plugins.*.configName` option must be set.
      '';
    };
  };
}
