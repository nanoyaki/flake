{
  pkgs,
  ...
}:

{
  modules.vr.enableAmdgpuPatch = true;
  modules.audio.latency = 32;

  environment.systemPackages = with pkgs; [
    protonvpn-gui
    imagemagick
  ];

  services.transmission = {
    enable = false;
    webHome = pkgs.flood-for-transmission;
    settings.download-dir = "/mnt/1TB-SSD/Torrents";
  };

  system.stateVersion = "24.11";
}
