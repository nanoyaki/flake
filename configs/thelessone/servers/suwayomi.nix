{
  lib,
  self,
  ...
}:

let
  extensionRepos = [ "https://github.com/keiyoushi/extensions" ];

  mkInstance =
    name: port:
    lib.nameValuePair name {
      enable = true;

      settings.server = {
        inherit port extensionRepos;
      };
    };
in

{
  imports = [
    self.nixosModules.suwayomi
  ];

  services.suwayomi = {
    enable = true;

    instances = builtins.listToAttrs [
      (mkInstance "thomas" 4555)
      (mkInstance "niklas" 4556)
      (mkInstance "hana" 4557)
    ];
  };
}
