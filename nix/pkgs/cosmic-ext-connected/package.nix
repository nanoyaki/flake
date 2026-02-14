{ withSystem, ... }:

{
  perSystem =
    { pkgs, ... }:

    {
      packages.cosmic-ext-connected = pkgs.callPackage (
        {
          lib,
          rustPlatform,
          applyPatches,
          fetchFromGitHub,
          just,
          pkg-config,
          libcosmicAppHook,
          dbus,
          glib,
          gtk3,
        }:

        rustPlatform.buildRustPackage (finalAttrs: {
          pname = "cosmic-ext-connected";
          version = "13fd5011bb89f8f720fbb12f263d37c24aa72dd1";

          src = applyPatches {
            name = "${finalAttrs.pname}-${finalAttrs.version}";
            src = fetchFromGitHub {
              owner = "nwxnw";
              repo = "cosmic-ext-connected";
              rev = finalAttrs.version;
              hash = "sha256-S4M5V1YV8FedYDdEtxSNiApIT3J2k+aIcq8D8V5H5p4=";
            };
            postPatch = ''
              ln -s ${./Cargo.lock} Cargo.lock
            '';
          };

          cargoDeps = rustPlatform.fetchCargoVendor {
            inherit (finalAttrs) src;
            hash = "sha256-YPTEPcgNHbWBkn3tpD8LA0QI5bQTOU9WkLTOwqgFP2s=";
          };

          nativeBuildInputs = [
            just
            pkg-config
            libcosmicAppHook
            rustPlatform.bindgenHook
          ];

          buildInputs = [
            dbus
            glib
            gtk3
          ];

          justFlags = [
            "--set"
            "prefix"
            (placeholder "out")
          ];

          meta = {
            homepage = "https://github.com/nwxnw/cosmic-ext-connected";
            description = "Phone connectivity applet for the COSMIC Desktop";
            license = lib.licenses.gpl3Only;
            maintainers = with lib.maintainers; [ nanoyaki ];
            platforms = lib.platforms.linux;
            mainProgram = "cosmic-ext-connected";
          };
        })
      ) { };
    };

  flake.overlays.cosmic-ext-connected =
    _: prev:

    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }:

      {
        inherit (config.packages) cosmic-ext-connected;
      }
    );
}
