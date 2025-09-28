{
  inputs,
  lib,
  lib',
  config,
  ...
}:

let
  inherit (inputs) flatpaks;
in

{
  options.config'.flatpak.enable = lib'.options.mkFalseOption;

  config = lib.mkIf config.config'.flatpak.enable {
    services.flatpak.enable = true;

    hms = [
      {
        imports = [
          flatpaks.homeModule
        ];

        services.flatpak = {
          forceRunOnActivation = true;
          remotes = {
            "flathub" = "https://flathub.org/repo/flathub.flatpakrepo";
            "flathub-beta" = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
          };
        };
      }
    ];
  };
}
