{
  lib,
  pkgs,
  inputs,
  username,
  ...
}:

let
  inherit (inputs) vermeer-undervolt;

  corectrlDesktop = pkgs.makeDesktopItem {
    name = pkgs.corectrl.pname;
    desktopName = "CoreCtrl";
    genericName = "Core control";
    comment = "Control your computer with ease using application profiles";
    exec = "${lib.getExe' pkgs.corectrl "corectrl"} --minimize-systray";
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
  imports = [
    vermeer-undervolt.nixosModules.vermeer-undervolt
  ];

  boot.kernelModules = [
    "kvm-amd"
    "ryzen_smu"
  ];

  hardware.cpu.amd.updateMicrocode = true;

  security.polkit.enable = true;
  hm.xdg.autostart.entries = [
    "${corectrlDesktop}/share/applications/${pkgs.corectrl.pname}.desktop"
  ];
  programs.corectrl = {
    enable = true;
    package = pkgs.corectrl;
  };
  users.users.${username}.extraGroups = [ "corectrl" ];

  services.vermeer-undervolt = {
    enable = true;
    cores = 8;
    milivolts = 30;
  };
}
