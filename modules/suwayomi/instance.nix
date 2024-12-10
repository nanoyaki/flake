{ lib, format }:

let
  inherit (lib) types mkOption mkEnableOption;
in

{
  options = {
    # Basepath /var/lib/suwayomi/<instanceName>/
    enable = mkEnableOption "this instance of suwayomi";

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to open the firewall for the port in {option}`services.suwayomi.instances.<name>.settings.server.port`.
      '';
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = format.type;

        options.server = {
          ip = mkOption {
            type = types.str;
            default = "0.0.0.0";
            example = "127.0.0.1";
            description = ''
              The IP address that Suwayomi will bind to.
            '';
          };

          port = mkOption {
            type = types.port;
            default = 8080;
            example = 4567;
            description = ''
              The port that Suwayomi will listen to.
            '';
          };

          downloadAsCbz = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Download chapters as `.cbz` files.
            '';
          };

          extensionRepos = mkOption {
            type = types.listOf types.str;
            default = [ ];
            example = lib.literalExpression ''
              [
                "https://raw.githubusercontent.com/MY_ACCOUNT/MY_REPO/repo/index.min.json"
              ];
            '';
            description = ''
              URL of repositories from which the extensions can be installed.
            '';
          };
        };
      };

      default = { };

      description = ''
        Configuration to write to {file}`server.conf`.
        See <https://github.com/Suwayomi/Suwayomi-Server/wiki/Configuring-Suwayomi-Server> for more information.
      '';

      example = lib.literalExpression ''
        {
          server.socksProxyEnabled = true;
          server.socksProxyHost = "yourproxyhost.com";
          server.socksProxyPort = 8080;
        };
      '';
    };
  };
}
