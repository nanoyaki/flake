{ withSystem, ... }:

{
  perSystem =
    { pkgs, ... }:

    {
      packages.starrydex = pkgs.callPackage (
        {
          lib,
          rustPlatform,
          fetchFromGitHub,
          pkg-config,
          libcosmicAppHook,
        }:

        rustPlatform.buildRustPackage (finalAttrs: {
          pname = "starrydex";
          version = "0.3.3";

          src = fetchFromGitHub {
            owner = "mariinkys";
            repo = "starrydex";
            rev = finalAttrs.version;
            hash = "sha256-ven5A/TrXFwMEEtsrzOU1xxFUTVJ6pbWs6ig5Iv1wKo=";
          };

          cargoHash = "sha256-EMYxSgQsi7CUOOe2VVYG3oiuWU9lDmfdsHC9dDF0NkU=";

          nativeBuildInputs = [
            pkg-config
            libcosmicAppHook
          ];

          buildInputs = [ ];

          preInstall = ''
            mkdir -p \
              $out/share/{applications,cosmic/dev.mariinkys.StarryDex,icons/hicolor/scalable/apps,metainfo}

            install -m644 $src/resources/app.desktop \
              $out/share/applications/dev.mariinkys.StarryDex

            install -m644 $src/resources/app.metainfo.xml \
              $out/share/metainfo/dev.mariinkys.StarryDex.metainfo.xml

            cp -a $src/resources/icons/hicolor/scalable/apps/icon.svg \
              $out/share/icons/hicolor/scalable/apps/dev.mariinkys.StarryDex.svg
          '';

          meta = {
            homepage = "https://github.com/mariinkys/starrydex";
            description = "Pokédex application for the COSMIC desktop";
            license = lib.licenses.gpl3;
            maintainers = with lib.maintainers; [ nanoyaki ];
            platforms = lib.platforms.linux;
            mainProgram = "starrydex";
          };
        })
      ) { };
    };

  flake.overlays.starrydex =
    _: prev:

    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }:

      {
        inherit (config.packages) starrydex;
      }
    );
}
