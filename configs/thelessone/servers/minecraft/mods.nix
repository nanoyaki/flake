{
  lib,
  linkFarmFromDrvs,
  additionalMods ? [ ],
  without ? [ ],
  fabricMods,
}:

linkFarmFromDrvs "mods" (
  with fabricMods.v1_21_7;
  (
    (lib.filter (mod: !(lib.elem mod without)) [
      fabric-api
      fabricproxy-lite
      simple-voice-chat
      vmp-fabric
      lithium
      player-roles
      no-chat-reports
      krypton
      c2me-fabric
      image2map
      netherportalfix
      balm
      ferrite-core
      scalablelux
      do-a-barrel-roll
      cicada
      servux
      rei
      architectury-api
      cloth-config
    ])
    ++ additionalMods
  )
)
