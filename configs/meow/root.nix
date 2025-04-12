{ lib, pkgs, ... }:

{
  home.homeDirectory = lib.mkForce "/";

  # vermeer-undervolt
  systemd.services.undervolt = {
    Unit.Description = "CPU undervolt";

    Service = {
      Type = "simple";
      User = "root";
      ExecStart = "${lib.getExe pkgs.vermeer-undervolt} 8 -30";
    };

    Install.WantedBy = [ "multi-user.target" ];
  };

  home.file."/etc/modules-load.d/vermeer-undervolt.conf".text = "ryzen_smu";

  # openrgb
  home.file."/etc/modules-load.d/openrgb.conf".text = ''
    i2c-dev
    i2c-piix4
  '';

  # corectrl
  home.packages = with pkgs; [ corectrl ];
  services.dbus.packages = [ pkgs.corectrl ];
  home.mappedPaths = {
    "share/polkit-1" = "/usr/share/polkit-1";
  };
  home.file."/etc/polkit-1/rules.d/90-corectrl.rules".text = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.corectrl.helper.init" ||
        action.id == "org.corectrl.helperkiller.init") &&
        subject.local == true &&
        subject.active == true &&
        subject.isInGroup("hana")) {
          return polkit.Result.YES;
      }
    });
  '';
}
