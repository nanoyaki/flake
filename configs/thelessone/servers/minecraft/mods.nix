{
  lib,
  fetchurl,
  linkFarmFromDrvs,
  additionalMods ? { },
  without ? [ ],
}:

linkFarmFromDrvs "mods" (
  lib.map fetchurl (
    builtins.attrValues (
      lib.filterAttrs (mod: _: !(lib.elem mod without)) (
        {
          FabricProxy-Lite = {
            sha512 = "3044f36df7e83021210a7c318def18a95b5dbf5e3230bb72a3ddb42ebdda33f248c6d12efcee1240ff0c54600d68d147afa105d04ee37a90acb9409619c89848";
            url = "https://cdn.modrinth.com/data/8dI2tmqs/versions/AQhF7kvw/FabricProxy-Lite-2.9.0.jar";
          };
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
          PlayerRoles = {
            sha512 = "32763f394c6511f10fd73ed88b364924f4027c83dbc42a5b1f2b738be8025f4e956c47fb9716c1f469da84d29900430fa17b0b7c75ceb85f64f2f914ad547a86";
            url = "https://cdn.modrinth.com/data/Rt1mrUHm/versions/aX5ZEmN4/player-roles-1.6.15.jar";
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
          FerriteCore = {
            sha512 = "131b82d1d366f0966435bfcb38c362d604d68ecf30c106d31a6261bfc868ca3a82425bb3faebaa2e5ea17d8eed5c92843810eb2df4790f2f8b1e6c1bdc9b7745";
            url = "https://cdn.modrinth.com/data/uXXizFIs/versions/CtMpt7Jr/ferritecore-8.0.0-fabric.jar";
          };
          ScalableLux = {
            sha512 = "ec8fabc3bf991fbcbe064c1e97ded3e70f145a87e436056241cbb1e14c57ea9f59ef312f24c205160ccbda43f693e05d652b7f19aa71f730caec3bb5f7f7820a";
            url = "https://cdn.modrinth.com/data/Ps1zyz6x/versions/PQLHDg2Q/ScalableLux-0.1.5%2Bfabric.e4acdcb-all.jar";
          };
          DoABarrelRoll = {
            sha512 = "0987105dcea3d36f477c277be7f2090454479137c50c4c2159da6862e438aeff07ae0e111844b66f60d9b9f796c79662a033a139a30e16b5030093ee9d852577";
            url = "https://cdn.modrinth.com/data/6FtRfnLg/versions/7nUPwWUG/do_a_barrel_roll-fabric-3.8.2%2B1.21.6.jar";
          };
          # Dependency of DoABarrelRoll
          Cicada = {
            sha512 = "00be5317c4ddae59be859a4d794cce58c425f9418651370a9dc425570bb316f15422e9ae78c2bf0ce8e39aad4a972a39b78f8c4cd8bcd7ac15f95bb51f709a5e";
            url = "https://cdn.modrinth.com/data/IwCkru1D/versions/2LuLtZUC/cicada-lib-0.13.1%2B1.21.5-and-above.jar";
          };
          Servux = {
            sha512 = "63f49e81fc004305cfba9e1228e2129b2ac0423f56fd7a4b23f6f591f409d2d5986a7642bdc5ee262fa87c8cbb4f052dd55ddf8274219d9693b379059adf4bfa";
            url = "https://cdn.modrinth.com/data/zQhsx8KF/versions/3LUmmXJf/servux-fabric-1.21.8-0.7.3.jar";
          };
          rei = {
            sha512 = "2870b06702ea7d0369e9a4c036c00b2ff87f69b4a925dc8c1b09012c715c1faf396a47100191d7a5c792e47618fe67e32f1055c3d3f6441ae8189b860303b47d";
            url = "https://cdn.modrinth.com/data/nfn13YXA/versions/t6ocxwV5/RoughlyEnoughItems-20.0.810-fabric.jar";
          };
          architectury-api = {
            sha512 = "7965ed7140c9f50cfcf8cf9b415de90497ae44ea4fb6dfe21704c6eba4210d0a34a4a0b0b6baf8b3e9d3b1cb70d0df79ef1ba93d04b5557f09a754959ac9c8b0";
            url = "https://cdn.modrinth.com/data/lhGA9TYQ/versions/XcJm5LH4/architectury-17.0.8-fabric.jar";
          };
          cloth-config = {
            sha512 = "924b7e9bf6da670b936c3eaf3a2ba7904a05eff4fd712acf8ee62e587770c05a225109d3c0bdf015992e870945d2086aa00e738f90b3b109e364b0105c08875a";
            url = "https://cdn.modrinth.com/data/9s6osm5g/versions/cz0b1j8R/cloth-config-19.0.147-fabric.jar";
          };
        }
        // additionalMods
      )
    )
  )
)
