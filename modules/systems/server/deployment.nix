{
  lib,
  lib',
  config,
  ...
}:

let
  inherit (lib) mapAttrs' nameValuePair;
  inherit (lib'.options)
    mkAttrsOf
    mkSubmoduleOption
    mkStrOption
    mkPathOption
    mkEither
    ;

  cfg = config.config'.deployment;
in

{
  # host = { ... };
  options.config'.deployment = mkAttrsOf (mkSubmoduleOption {
    # username; usually root
    targetUser = mkStrOption;
    privateKeyName = mkStrOption;
    # key or key contents
    publicKey = mkEither mkPathOption mkStrOption;
  });

  config.users.users = mapAttrs' (
    host: deployment:
    nameValuePair deployment.targetUser {
      openssh.authorizedKeys.keys = [
        (
          if (builtins.typeOf cfg.${host}.publicKey) == "path" then
            builtins.readFile cfg.${host}.publicKey
          else
            cfg.${host}.publicKey
        )
      ];
    }
  ) cfg;
}
