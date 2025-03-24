let
  csCfgDir = "Steam/steamapps/common/Counter-Strike Global Offensive/game/core/cfg";
in

{
  hm.xdg.dataFile = {
    "${csCfgDir}/chat.cfg".text = ''
      bind o "say A girl without her penis is like an angel without its wings..."
      bind p "exec girls.cfg"
    '';

    "${csCfgDir}/girls.cfg".text = "say Real women > \"girls\" with vaginas";
  };
}
