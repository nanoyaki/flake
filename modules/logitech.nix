{ config, ... }:

{
  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.logitech ];
  };

  modules.nixos.logitech = {
    nixpkgs.overlays = [ config.overlays.solaar ];

    hardware.logitech.wireless.enable = true;
    programs.solaar.enable = true;
  };

  modules.home.logitech =
    { lib, ... }:

    let
      inherit (lib) mkEnableOption;
    in

    {
      options.programs.solaar.enable = mkEnableOption "solaar" // {
        default = true;
      };
    };

  modules.home.niri =
    {
      lib,
      options,
      config,
      ...
    }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf ((options ? programs.solaar.enable) && config.programs.solaar.enable) {
        programs.niri.settings.spawn-at-startup = [ { command = [ "solaar" ]; } ];
      };
    };

  perSystem =
    { pkgs, ... }:

    {
      packages.solaar = pkgs.symlinkJoin {
        inherit (pkgs.solaar) pname version;
        paths = [ pkgs.solaar ];
        postBuild = ''
          cp $out/share/applications/solaar.desktop solaar.desktop
          rm $out/share/applications/solaar.desktop

          substitute solaar.desktop $out/share/applications/solaar.desktop \
            --replace-fail "solaar" 'solaar -w hide'

          ln -s ${pkgs.solaar.udev} $udev
        '';
        outputs = [
          "out"
          "udev"
        ];
      };
    };

  overlays.solaar = { config, ... }: {
    inherit (config.packages) solaar;
  };
}
