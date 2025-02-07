{
  pkgs,
  inputs,
  username,
  ...
}:

let
  inherit (inputs) vermeer-undervolt;

  corectrl = pkgs.corectrl.overrideAttrs {
    patches = [
      ./corectrl/polkit-dir.patch
      ./corectrl/systray.patch
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
  hm.xdg.autostart.entries = [ "${corectrl}/share/applications/org.corectrl.CoreCtrl.desktop" ];
  programs.corectrl = {
    enable = true;
    package = corectrl;
    gpuOverclock.enable = true;
    gpuOverclock.ppfeaturemask = "0xffffffff";
  };
  users.users.${username}.extraGroups = [ "corectrl" ];

  services.vermeer-undervolt = {
    enable = true;
    cores = 8;
    milivolts = 30;
  };
}
