{ config, ... }:

{
  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.linux-zen ];
  };

  modules.nixos.linux-zen =
    { pkgs, ... }:

    {
      boot.kernelPackages = pkgs.linuxPackages_zen;
    };
}
