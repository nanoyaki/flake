{ lib, config, ... }:

let
  inherit (lib) mkOption types;

  cfg = config.deployment;
in

{
  options.deployment = {
    targetUser = mkOption {
      type = types.str;
      example = lib.literalExpression ''
        "username"
      '';
    };

    targetHost = mkOption {
      type = types.str;
      example = lib.literalExpression ''
        "127.0.0.1"
      '';
    };

    privateKeyName = mkOption {
      type = types.str;
      example = lib.literalExpression ''
        "remoteHostDeploymentKey"
      '';
    };

    publicKey = mkOption {
      type = types.either types.path types.str;
      example = lib.literalExpression ''
        ./remoteHostDeploymentKey.pub
      '';
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = lib.literalExpression ''
        [ 
          "--use-remote-sudo"
          "--print-build-logs"
        ]
      '';
    };
  };

  config = {
    users.users.${cfg.targetUser}.openssh.authorizedKeys.keys = lib.singleton (
      if (builtins.typeOf cfg.publicKey) == "path" then builtins.readFile cfg.publicKey else cfg.publicKey
    );
  };
}
