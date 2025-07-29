{
  lib,
  linkFarmFromDrvs,
  datapacks,
  gamerules ? { },
}:

linkFarmFromDrvs "datapacks" (
  lib.attrValues (datapacks // { gamerules = datapacks.gamerules gamerules; })
)
