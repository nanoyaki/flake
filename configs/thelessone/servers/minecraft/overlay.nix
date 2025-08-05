final: _: {
  fabricModpacks = {
    default = final.callPackage ./mods.nix { };

    smp = final.fabricModpacks.default.override {
      additionalMods = with final.fabricMods.v1_21_7; [
        bluemap
        bluemap-sign-markers
        discord-mc-chat
        distanthorizons
      ];
    };

    creative = final.fabricModpacks.default.override {
      additionalMods = with final.fabricMods.v1_21_7; [
        axiom
        carpet
      ];
    };
  };

  datapackSet = {
    default =
      gamerules:
      final.callPackage ./datapacks.nix {
        inherit gamerules;
        datapacks = final.datapacks // {
          inherit (final.datapackSet) gamerules;
        };
      };
    gamerules = gamerules: final.callPackage ./declarative-gamerules.nix { inherit gamerules; };
  };
}
