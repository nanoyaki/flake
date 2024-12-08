{ lib, pkgs }:

let
  inherit (lib) types mkOption;

  format = pkgs.formats.yaml { };
in

{
  options = {
    name = mkOption {
      type = types.nullOr types.str;
      example = "youtube";
      default = null;
      description = ''
        The name of the plugin to use for the plugin configuration.
      '';
    };

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
      '';
    };

    snapshot = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''
        Whether to use the snapshot repository instead of the release repository.
      '';
    };

    hash = mkOption {
      type = types.str;
      example = lib.fakeHash;
      default = lib.fakeHash;
      description = ''
        The hash of the plugin.
      '';
    };

    extraConfig = mkOption {
      type = types.submodule { freeformType = format.type; };
      default = { };
      description = ''
        The configuration for the plugin.

        The option
      '';
    };
  };
}
