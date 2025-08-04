{ killheal }:

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
    default = final.callPackage ./datapacks.nix {
      datapacks = final.datapacks // {
        inherit (final.datapackSet) gamerules killheal;
      };
    };
    inherit killheal;
    gamerules = gamerules: final.callPackage ./declarative-gamerules.nix { inherit gamerules; };
  };
}
