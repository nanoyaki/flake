final: _: {
  fabricMods = {
    default = final.callPackage ./mods.nix { };

    smp = final.fabricMods.default.override {
      additionalMods = {
        Bluemap = {
          sha512 = "a76a2b1019efe35175f8df91f69ec7ec58e26f148ea9bba4f1eb9bb1b16ffa6f395b76c1362f452d33f94f0f1045403da3b04f25bc6d40feadbc58f64d34f1e4";
          url = "https://cdn.modrinth.com/data/swbUV1cr/versions/fB6f4XRA/bluemap-5.9-fabric.jar";
        };
        BluemapSignMarkers = {
          sha512 = "d3efb15a03ef3dcc02bcd2395c578afdc2d413d5e4dfcf65c9cad891e755ade9d6a7961e7b0f07e7e229b831d11d6459efdb5a935d0e5597c1782ec9ca8e2b41";
          url = "https://cdn.modrinth.com/data/i5ZtmNIW/versions/vCOKmCcE/bluemapsignmarkers-1.21.7-0.11.0.56.jar";
        };
        DiscordMcChat = {
          sha512 = "5d653d21048cea1eeaff13bf1f63619133384385b4da21c5105c64e4b1b6ac67c04fd8534768d0a5125a9c940a4dc38ce64cba6b202e86e705a5ef9b45a8c4d5";
          url = "https://cdn.modrinth.com/data/D0sHdnXY/versions/PtVawIb0/Discord-MC-Chat-2.5.0.jar";
        };
        DistantHorizons = {
          sha512 = "5f8d4e564f65dcbe5e039af8605da4df8a8edcc2218a46aad827aaa8d1e8848adb302672735f579715be1c480956dd6dd7548a2bff9bacc4f0ef0592eeceb238";
          url = "https://cdn.modrinth.com/data/uCdwusMi/versions/2mY04ehi/DistantHorizons-2.3.3-b-1.21.7-fabric-neoforge.jar";
        };
      };
    };

    creative = final.fabricMods.default.override {
      additionalMods = {
        Axiom = {
          sha512 = "4aafc025ad5e652060f7cff74dade9fcc6ec770a5f310fe970eedd6f6c7154c6cc10a33e0fbe9c648bed736b552ea645c530ce92f371acbcd6c93a6f313ca4b5";
          url = "https://cdn.modrinth.com/data/N6n5dqoA/versions/CRjwbqnJ/Axiom-4.9.1-for-MC1.21.6.jar";
        };
        carpet = {
          sha512 = "f03f80017538fd051a162feca58c1fa344d45d34b70cde27c10d465c371f9a11ddc80229e159b3439901cc8a6084f6672b62e5441f8d921fc2850ffd7e41e9c1";
          url = "https://cdn.modrinth.com/data/TQTTVgYE/versions/RXcxPvgC/fabric-carpet-1.21.7-1.4.177%2Bv250630.jar";
        };
      };
    };
  };

  datapacks.default = final.callPackage ./datapacks.nix { };
}
