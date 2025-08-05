{
  lib,
  linkFarmFromDrvs,
  datapacks,
  gamerules ? { },
  additionalDatapacks ? [ ],
}:

linkFarmFromDrvs "datapacks" (
  (lib.attrValues (datapacks.v1_21_7 // { gamerules = datapacks.gamerules gamerules; }))
  ++ additionalDatapacks
)
