{ withSystem, config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.theme ];
  };

  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.theme ];
  };

  modules.nixos.theme =
    { lib, config, ... }:

    let
      inherit (lib) mkOption types;
    in

    {
      options.environment.theme.wallpaper = mkOption {
        type = types.nullOr types.storePath;
        default = withSystem config.nixpkgs.hostPlatform (
          { config, ... }: config.packages.wallpaper.outPath
        );
        defaultText = "withSystem config.nixpkgs.hostPlatform ({ config, ... }: config.packages.wallpaper.outPath)";
      };
    };

  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.theme ];
  };

  configurations.home."hana@shirayuri" = {
    imports = [ config.modules.home.theme ];
  };

  modules.home.theme =
    { lib, pkgs, ... }:

    let
      inherit (lib) mkDefault;
    in

    {
      home.pointerCursor = mkDefault {
        enable = true;
        x11.enable = true;
        gtk.enable = true;

        size = 32;
        name = "Wii-Pointer-P1";
        package = withSystem pkgs.stdenv.hostPlatform.system ({ config, ... }: config.packages.cursor);
      };
    };

  perSystem =
    { pkgs, ... }:

    {
      packages.wallpaper = pkgs.fetchPixivIllust {
        id = 140824539;
        hash = "sha256-MjEEnE6t4B2zhGE1oDCpMGGQO9rI97eFnhH4Nz4P9X0=";
      };

      packages.wallpaper2 = pkgs.fetchPixivIllust {
        id = 101272718;
        hash = "sha256-5kCaGJ8RgfpKA13ZsMHchfCX1lS/y9nlU9OCwQ91FX4=";
      };

      packages.cursor = pkgs.fetchzip {
        url = "https://web.archive.org/web/20260806074648/https://files.primm.gay/extras/cursors/Wii/Linux%20Cursors%20Scalable.7z";
        hash = "sha256-Q1Aq2gAK/nsW4lpAI9smm9y6u9TnoVLn6q1CqmL6chM=";
        stripRoot = false;
        nativeBuildInputs = [ pkgs.p7zip ];

        postFetch = ''
          mkdir $out/share/icons -p
          rm -f $out/README.txt
          mv $out/Wii* $out/share/icons
        '';
      };
    };
}
