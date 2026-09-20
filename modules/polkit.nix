{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.polkit ];
  };

  modules.nixos.polkit = {
    security.polkit.enable = true;
    security.polkit.enablePkexecWrapper = true;
  };

  modules.nixos.noctalia =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    let
      inherit (lib)
        mkIf
        foldl
        attrValues
        concatMapStringsSep
        getExe'
        optional
        ;

      noctaliaUsers = foldl (
        users: cfg:

        users
        ++ optional (
          cfg.isNormalUser
          && config ? home-manager.users.${cfg.name}
          && config.home-manager.users.${cfg.name}.programs.noctalia.enable
        ) cfg.name
      ) [ ] (attrValues config.users.users);
    in

    {
      config = mkIf config.security.polkit.enable {
        security.polkit.extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (action.id == "org.noctalia.greeter.sync-appearance" &&
                action.lookup("program") == "${getExe' pkgs.noctalia-greeter "noctalia-greeter-apply-appearance"}" &&
                action.lookup("user") == "root" &&
                subject.local && subject.active &&
                [${
                  concatMapStringsSep ", " (user: "\"${user}\"") noctaliaUsers
                }].indexOf(subject.user) >= 0) {
              return polkit.Result.YES;
            }
          });
        '';
      };
    };
}
