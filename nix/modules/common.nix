{
  flake.nixosModules.common =
    { lib, config, ... }:

    let
      inherit (lib) mkOption types;

      cfg = config.self;
    in

    {
      options.self = {
        mainUser = mkOption {
          type = types.str;
          default = "";
        };

        mainUserHome = mkOption {
          type = with types; nullOr path;
          default =
            if config.users.users ? cfg.mainUser then config.users.users.${cfg.mainUser}.home else null;
        };
      };

      config = {
        assertions = [
          {
            assertion = cfg.mainUser != "";
            message = ''
              Make sure to set {option}`self.mainUser`
            '';
          }
          {
            assertion = cfg.mainUserHome != null;
            message = ''
              The user doesn't exist, therefore the home can't get determined
            '';
          }
        ];

        programs.git.enable = true;
        programs.git.lfs.enable = true;
      };
    };
}
