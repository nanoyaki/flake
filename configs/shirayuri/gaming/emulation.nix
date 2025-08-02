{ pkgs, ... }:

{
  hm.home.packages = with pkgs; [
    (lazy-app.override {
      pkg = dolphin-emu;
      desktopItem = makeDesktopItem {
        desktopName = "Dolphin Emulator";
        name = "dolphin-emulator";
        icon = "dolphin-emu";
        exec = "dolphin-emu";
        terminal = false;
        type = "Application";
        categories = [
          "Game"
          "Emulator"
        ];
        genericName = "Wii/GameCube Emulator";
        comment = "A Wii/GameCube Emulator";
      };
    })
    (lazy-app.override {
      pkg = melonDS;
      desktopItem = makeDesktopItem {
        desktopName = "melonDS";
        icon = "net.kuribo64.melonDS";
        name = "melonDS";
        genericName = "Nintendo DS Emulator";
        comment = "A fast and accurate Nintendo DS emulator";
        exec = "melonDS %f";
        type = "Application";
        categories = [
          "Game"
          "Emulator"
        ];
        terminal = false;
        mimeTypes = [ "application/x-nintendo-ds-rom" ];
        keywords = [
          "emulator"
          "Nintendo"
          "DS"
          "NDS"
          "Nintendo DS"
        ];
      };
    })
  ];

  services.restic.extraPaths = [
    # Wii game save states
    "/home/hana/.local/share/dolphin-emu"
  ];
}
