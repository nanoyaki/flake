{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.plymouth ];
  };

  modules.nixos.plymouth =
    { pkgs, ... }:

    {
      boot.plymouth = {
        enable = true;
        themePackages = [ pkgs.plymouth-blahaj-theme ];
        theme = "blahaj";
      };
    };
}
