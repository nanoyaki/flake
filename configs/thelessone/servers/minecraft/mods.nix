{
  lib,
  fetchurl,
  linkFarmFromDrvs,
}:

linkFarmFromDrvs "mods" (
  builtins.attrValues (
    lib.mapAttrs (_: fetchurl) {
      FabricApi = {
        sha512 = "43bf6af145a6b450503a6d7e7ec9a34912bd1494969b5d8861067f0f846cf710805415fb0fbc93c9ae9f5164d45c7649342f84b4f34552b2abdd892fd3b9838e";
        url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/JntuF9Ul/fabric-api-0.129.0%2B1.21.7.jar";
      };
      SimpleVoiceChat = {
        sha512 = "501bcd3648f987f450b4996df97c75c95ada0396027987367335fe0315313566f5b67972d3012e8bbec268a28f4d8e541a34f766dfc314b024bc72afc2c0bab4";
        url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/YjxCZ3Wx/voicechat-fabric-1.21.7-2.5.34.jar";
      };
      VeryManyPlayers = {
        sha512 = "f2830ee9403f26caf6189ba3d9f185bf77c087bba6973cc2960cf01623076e5935689ee366fe88087aa43f92a73128208e50333789acd433e59feccb9f371f55";
        url = "https://cdn.modrinth.com/data/wnEe9KBa/versions/fcuAO34V/vmp-fabric-mc1.21.7-0.2.0%2Bbeta.7.202-all.jar";
      };
      Lithium = {
        sha512 = "afaf6ddaf0cbae2050d725efd438c4c98141d738a637f0f058dcbaff077ef85af801e2dca138ce9f7f8ba3a169dc6af1c9f56736b255c6ea13363f8a1be8ecdb";
        url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/77EtzYFA/lithium-fabric-0.18.0%2Bmc1.21.7.jar";
      };
      Chunky = {
        sha512 = "9e0386d032641a124fd953a688a48066df7f4ec1186f7f0f8b0a56d49dced220e2d6938ed56e9d8ead78bb80ddb941bc7873f583add8e565bdacdf62e13adc28";
        url = "https://cdn.modrinth.com/data/fALzjamp/versions/inWDi2cf/Chunky-Fabric-1.4.40.jar";
      };
      Bluemap = {
        sha512 = "a76a2b1019efe35175f8df91f69ec7ec58e26f148ea9bba4f1eb9bb1b16ffa6f395b76c1362f452d33f94f0f1045403da3b04f25bc6d40feadbc58f64d34f1e4";
        url = "https://cdn.modrinth.com/data/swbUV1cr/versions/fB6f4XRA/bluemap-5.9-fabric.jar";
      };
      DistantHorizons = {
        sha512 = "5f8d4e564f65dcbe5e039af8605da4df8a8edcc2218a46aad827aaa8d1e8848adb302672735f579715be1c480956dd6dd7548a2bff9bacc4f0ef0592eeceb238";
        url = "https://cdn.modrinth.com/data/uCdwusMi/versions/2mY04ehi/DistantHorizons-2.3.3-b-1.21.7-fabric-neoforge.jar";
      };
      PlayerRoles = {
        sha512 = "32763f394c6511f10fd73ed88b364924f4027c83dbc42a5b1f2b738be8025f4e956c47fb9716c1f469da84d29900430fa17b0b7c75ceb85f64f2f914ad547a86";
        url = "https://cdn.modrinth.com/data/Rt1mrUHm/versions/aX5ZEmN4/player-roles-1.6.15.jar";
      };
      BluemapSignMarkers = {
        sha512 = "d3efb15a03ef3dcc02bcd2395c578afdc2d413d5e4dfcf65c9cad891e755ade9d6a7961e7b0f07e7e229b831d11d6459efdb5a935d0e5597c1782ec9ca8e2b41";
        url = "https://cdn.modrinth.com/data/i5ZtmNIW/versions/vCOKmCcE/bluemapsignmarkers-1.21.7-0.11.0.56.jar";
      };
      NoChatReports = {
        sha512 = "6e93c822e606ad12cb650801be1b3f39fcd2fef64a9bb905f357eb01a28451afddb3a6cadb39c112463519df0a07b9ff374d39223e9bf189aee7e7182077a7ae";
        url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/LhwpK0O6/NoChatReports-FABRIC-1.21.7-v2.14.0.jar";
      };
      # Noisium = {
      #   sha512 = "3119f9325a9ce13d851d4f6eddabade382222c80296266506a155f8e12f32a195a00a75c40a8d062e4439f5a7ef66f3af9a46f9f3b3cb799f3b66b73ca2edee8";
      #   url = "https://cdn.modrinth.com/data/KuNKN7d2/versions/9NHdQfkN/noisium-fabric-2.5.0%2Bmc1.21.4.jar";
      # };
      Krypton = {
        sha512 = "2e2304b1b17ecf95783aee92e26e54c9bfad325c7dfcd14deebf9891266eb2933db00ff77885caa083faa96f09c551eb56f93cf73b357789cb31edad4939ffeb";
        url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/neW85eWt/krypton-0.2.9.jar";
      };
      C2MEngine = {
        sha512 = "8942e82c216315198d4752fbb9396e6d59d6447085ce5c00811ba0189765b20acad0153a10532f7ade29f7c090e0299c01802174aa89d4da642bc10f9429998d";
        url = "https://cdn.modrinth.com/data/VSNURh3q/versions/Erjpfj2l/c2me-fabric-mc1.21.7-0.3.4%2Bbeta.1.0.jar";
      };
      Image2Map = {
        sha512 = "a7395093dfeafcd7d4f91240b824b6a0484848ed534eadf0e677e9d0688a0c1d84f96250f761058142846ec61d50dee0cc898dceeb4bc1e673abfdf70b4d0e34";
        url = "https://cdn.modrinth.com/data/13RpG7dA/versions/bJYNHoyD/image2map-0.10.1%2B1.21.6.jar";
      };
      NetherPortalFix = {
        sha512 = "d4bda547aa53738a2eb0eeff4819d159368e5176c3a6ae8dc6e4f60476bf01d47817b1c99285f5af9c1a592a77fe4fb5ab9b08546bb250af979f399e97752bd0";
        url = "https://cdn.modrinth.com/data/nPZr02ET/versions/wKtrSBPH/netherportalfix-fabric-1.21.7-21.7.1.jar";
      };
      Balm = {
        sha512 = "566c3b74969bd2ab3dd3a1f5946574ffcb0a54f55c16ba932a4ef9b150a1b64c94ab6053c06506c98e1b579b199329deb75092a43836233d347151f8466da90a";
        url = "https://cdn.modrinth.com/data/MBAkmtvl/versions/l2DAvB9Q/balm-fabric-1.21.7-21.7.2.jar";
      };
      DiscordMcChat = {
        sha512 = "5d653d21048cea1eeaff13bf1f63619133384385b4da21c5105c64e4b1b6ac67c04fd8534768d0a5125a9c940a4dc38ce64cba6b202e86e705a5ef9b45a8c4d5";
        url = "https://cdn.modrinth.com/data/D0sHdnXY/versions/PtVawIb0/Discord-MC-Chat-2.5.0.jar";
      };
    }
  )
)
