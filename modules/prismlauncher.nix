{ config, ... }:

{
  configurations.home."hana@shirayuri" = {
    imports = [ config.modules.home.prismlauncher ];
  };

  modules.home.prismlauncher =
    { pkgs, ... }:

    {
      nixpkgs.overlays = [ config.overlays.prismlauncher ];
      home.packages = [ pkgs.prismlauncher ];
    };

  perSystem =
    { lib, pkgs, ... }:

    {
      packages.prismlauncher = pkgs.symlinkJoin {
        inherit (pkgs.prismlauncher) pname version;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        paths = [
          (pkgs.prismlauncher.override {
            jdks = with pkgs; [
              zulu25
              zulu21
              zulu17
              zulu8
            ];
            additionalLibs = with pkgs; [
              sdl3
            ];
          })
        ];
        postBuild = with pkgs; ''
          wrapProgram $out/bin/prismlauncher \
            --prefix XDG_DATA_DIRS : "${
              lib.concatStringsSep ":" [
                "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"
                "${gtk3}/share/gsettings-schemas/${gtk3.name}"
              ]
            }"
        '';
      };
    };

  overlays.prismlauncher = { config, ... }: {
    inherit (config.packages) prismlauncher;
  };
}
