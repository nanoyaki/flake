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

  programs.steam.extraCompatPackages = [
    (pkgs.proton-ge-rtsp-bin.overrideAttrs rec {
      version = "GE-Proton9-22-rtsp17-1";
      src = pkgs.fetchzip {
        url = "https://github.com/SpookySkeletons/proton-ge-rtsp/releases/download/${version}/${version}.tar.gz";
        hash = "sha256-GeExWNW0J3Nfq5rcBGiG2BNEmBg0s6bavF68QqJfuX8=";
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    # index_camera_passthrough
    lighthouse-steamvr

    openal
  ];
}
