{
  inputs',
  pkgs,
  username,
  ...
}:

{
  sec."deployment/private".owner = username;

  modules.audio.latency = 32;

  environment.systemPackages =
    (with pkgs; [
      protonvpn-gui
      imagemagick

      winetricks
      wineWowPackages.stableFull
    ])
    ++ [
      inputs'.deploy-rs.packages.deploy-rs
    ];

  programs.droidcam.enable = true;

  services.transmission = {
    enable = false;
    webHome = pkgs.flood-for-transmission;
    settings.download-dir = "/mnt/os-shared/Torrents";
  };

  hm.xdg.desktopEntries.windows = {
    name = "Windows";
    comment = "Reboot to Windows";
    exec = "sudo systemctl reboot --boot-loader-entry=auto-windows";
    icon = "${pkgs.catppuccin-papirus-folders}/share/icons/Papirus/64x64/apps/windows95.svg";
    categories = [ "System" ];
    terminal = false;
  };

  hm.news.display = "show";

  system.stateVersion = "24.11";
  hm.home.stateVersion = "24.11";
}
