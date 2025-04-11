{
  lib,
  lib'',
  pkgs,
  ...
}:

let
  corectrlDesktop = pkgs.makeDesktopItem {
    name = pkgs.corectrl.pname;
    desktopName = "CoreCtrl";
    genericName = "Core control";
    comment = "Control your computer with ease using application profiles";
    exec = "${lib.getExe pkgs.corectrl} --minimize-systray";
    icon = "corectrl";
    startupNotify = true;
    startupWMClass = "corectrl";
    terminal = false;
    categories = [
      "System"
      "Settings"
      "Utility"
    ];
    keywords = [
      "control"
      "system"
      "hardware"
      "frequency"
      "fan"
      "voltage"
      "overclock"
      "underclock"
      "gpu"
      "cpu"
    ];
  };
in

{
  nixpkgs.overlays = [
    (lib''.nixGlOverlay [ "corectrl" ])
  ];

  home.packages = with pkgs; [
    corectrl
    vermeer-undervolt
  ];

  xdg.autostart.entries = [
    "${corectrlDesktop}/share/applications/${pkgs.corectrl.pname}.desktop"
  ];
}
