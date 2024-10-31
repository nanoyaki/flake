{
  pkgs,
  inputs,
  config,
  username,
  ...
}:

let
  inherit (inputs) vermeer-undervolt;
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
  hm.home.file."${config.hm.xdg.configHome}/autostart/org.corectrl.CoreCtrl.desktop".source = config.hm.lib.file.mkOutOfStoreSymlink "${pkgs.corectrl}/share/applications/org.corectrl.CoreCtrl.desktop";
  programs.corectrl = {
    enable = true;
    gpuOverclock.enable = true;
    gpuOverclock.ppfeaturemask = "0xffffffff";
  };
  users.users."${username}".extraGroups = [ "corectrl" ];

  services.vermeer-undervolt = {
    enable = true;
    cores = 8;
    milivolts = 30;
  };
}
