{ lib, pkgs, ... }:

{
  home.homeDirectory = lib.mkForce "/";

  # vermeer-undervolt
  home.file."/etc/modules-load.d/vermeer-undervolt.conf".text = "ryzen_smu";

  # openrgb
  home.file."/etc/modules-load.d/openrgb.conf".text = ''
    i2c-dev
    i2c-piix4
  '';

  # corectrl
  home.file."/usr/share/polkit-1/actions/org.corectrl.helper.policy".source =
    "${pkgs.corectrl}/share/polkit-1/actions/org.corectrl.helper.policy";
  home.file."/usr/share/polkit-1/actions/org.corectrl.helperkiller.policy".source =
    "${pkgs.corectrl}/share/polkit-1/actions/org.corectrl.helperkiller.policy";
  home.file."/usr/share/dbus-1/system-services/org.corectrl.helper.service".source =
    "${pkgs.corectrl}/share/dbus-1/system-services/org.corectrl.helper.service";
  home.file."/usr/share/dbus-1/system-services/org.corectrl.helperkiller.service".source =
    "${pkgs.corectrl}/share/dbus-1/system-services/org.corectrl.helperkiller.service";
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
