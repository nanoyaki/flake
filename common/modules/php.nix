{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.services.nano.php;
in {
  options.services.nano.php = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable custom gaming options.";
    };

    withSymfony = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to add the symfony-cli.";
    };

    withPhpstorm = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to add the PHPStorm IDE.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # PHP
      (pkgs.php83.buildEnv {
        extensions = {
          enabled,
          all,
        }:
          enabled ++ (with all; [mongodb redis]);
      })
      php83Packages.phpstan
      php83Packages.composer
      (mkIf cfg.withSymfony symfony-cli)
      (mkIf cfg.withPhpstorm jetbrains.phpstorm)
    ];
  };
}
