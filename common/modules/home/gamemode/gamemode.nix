{sysconfig, ...}: {
  home.file.".config/gamemode.ini".text = ''
    [custom]
    start=qdbus org.kde.KWin /Compositor suspend
    end=qdbus org.kde.KWin /Compositor resume
  '';
}
