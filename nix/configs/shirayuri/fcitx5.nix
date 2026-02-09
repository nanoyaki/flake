{
  flake.nixosModules.shirayuri-fcitx5 =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    let
      fcitx5Package = pkgs.qt6Packages.fcitx5-with-addons.override {
        inherit (config.i18n.inputMethod.fcitx5) addons;
      };
    in

    {
      i18n.inputMethod.package = lib.mkForce (
        pkgs.symlinkJoin {
          inherit (fcitx5Package) name;
          paths = [ fcitx5Package ];
          postBuild = ''
            rm $(find $out/share/applications -not -name "fcitx5*" -not -type d)
          '';
        }
      );
    };
}
