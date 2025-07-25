{
  lib,
  fetchurl,
  linkFarmFromDrvs,
}:

linkFarmFromDrvs "datapacks" (
  lib.map fetchurl (
    builtins.attrValues {
      MiniBlocks = {
        sha512 = "2de182e777bf8aa1e7235c18d89c0731c5de7f903e34869d51aeaabd8d3e223664ec5d51b0443b247296c8d23d289963319674e38aa0b1aea36de0cf3193eb94";
        url = "https://cdn.modrinth.com/data/sqhvLNrE/versions/UDWYQbTE/mini-blocks-v1-5-0-mc-1-21-7.zip";
      };
      joshs-more-foods = {
        sha512 = "08fa0151e8b92b842d72bc6f0496121c5fdb112423648854fdc1cbc1f9dbc0b725067c636d8a4417ccd87a925805f1d60c3c7fd0e8ac961f92c2e4baab572052";
        url = "https://cdn.modrinth.com/data/3BlwZj8w/versions/bybBGRCd/joshs-more-foods_5.5.1_data_pack.zip";
      };
    }
  )
)
