{
  lib,
  linkFarmFromDrvs,
  datapacks,
  gamerules ? { },
  additionalDatapacks ? { },
}:

linkFarmFromDrvs "datapacks" (
  lib.attrValues (datapacks // { gamerules = datapacks.gamerules gamerules; } // additionalDatapacks)
)
