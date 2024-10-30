{
  pkgs,
  config,
  username,
  packages,
  ...
}:
{
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

  services.x3d-undervolt = {
    enable = true;
    package = packages.x3d-undervolt.overrideAttrs {
      meta.license = [ ];
      meta.mainProgram = "x3d-undervolt";
    };
    cores = 8;
    milivolts = 30;
  };
}
