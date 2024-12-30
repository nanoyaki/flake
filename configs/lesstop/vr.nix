{
  lib,
  pkgs,
  packages,
  ...
}:

let
  ft-pkg = (
    pkgs.writeShellScriptBin "facetracking" ''
      trap 'jobs -p | xargs kill' EXIT

      ${lib.getExe pkgs.vrcadvert} OscAvMgr 9402 9000 --tracking &

      # If using WiVRn
      ${lib.getExe pkgs.oscavmgr} openxr
    ''
  );
in

{
  environment.systemPackages = [
    packages.startvrc
    pkgs.motoc
    (pkgs.writeShellScriptBin "startvr" ''
      trap 'jobs -p | xargs kill' EXIT

      systemctl --user start wivrn.service

      ${lib.getExe ft-pkg} &

      echo 'Sobald connected, folgenden Befehl für das Overlay ausführen:

      systemctl --user start wlx-overlay-s.service

      und danach mit: 

      PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/wivrn/comp_ipc nvidia-offload %command%

      ein Spiel starten. Bei VRC:

      PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/wivrn/comp_ipc startvrc nvidia-offload %command%'
    '')
  ];

  services.wivrn.package = pkgs.wivrn.override {
    cudaPackages = pkgs.cudaPackages_12_4;
    cudaSupport = true;
  };

  services.wivrn.config.json = {
    # 1.0x foveation scaling
    scale = 1;
    # 300 Mb/s
    bitrate = 300000000;
    encoders = [
      {
        encoder = "nvenc";
        codec = "h265";
        # 1.0 x 1.0 scaling
        width = 1.0;
        height = 1.0;
        offset_x = 0.0;
        offset_y = 0.0;
      }
    ];
  };
}
