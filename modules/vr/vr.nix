{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.nixpkgs-xr.nixosModules.nixpkgs-xr
  ];

  nixpkgs.xr.enable = true;

  hm.home.file.".alsoftrc".text = ''
    hrtf = true
  '';

  programs.steam.package = pkgs.steam.override {
    extraProfile = ''
      unset TZ
      export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
    '';
  };
  programs.steam.extraCompatPackages = [ pkgs.proton-ge-rtsp-bin ];

  environment.systemPackages = with pkgs; [
    index_camera_passthrough
    lighthouse-steamvr

    openal
  ];
}
