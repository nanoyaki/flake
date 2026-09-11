{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.xdg ];
  };

  modules.nixos.xdg = {
    xdg = {
      autostart.enable = true;
      mime.enable = true;
      terminal-exec.enable = true;
    };
  };

  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.xdg ];
  };

  modules.home.xdg = {
    xdg = {
      enable = true;
      autostart.enable = true;
      mime.enable = true;
      mimeApps.enable = true;
      terminal-exec.enable = true;
    };
  };
}
