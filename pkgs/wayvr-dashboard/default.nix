{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchNpmDeps,
  pkg-config,
  cargo-tauri,
  nodejs,
  npmHooks,
  glib,
  gtk3,
  gtk4,
  webkitgtk_4_1,
  libsoup_3,
  alsa-lib,
}:

let
  pname = "wayvr-dashboard";
  version = "9246f42ddb00301fbc46d3c2999736894b2ae615";

  src = fetchFromGitHub {
    owner = "olekolek1000";
    repo = pname;
    rev = version;
    hash = "sha256-EPpa6uJcim0DfgucxXEEQjqVyFDQUeoKZMsz7X6as0g=";
  };

  cargoRoot = "src-tauri";
in

rustPlatform.buildRustPackage {
  inherit pname version src;

  useFetchCargoVendor = true;
  cargoHash = "sha256-+rSyIf0GOuMKEbPrQJO+RufmTyMrSX49EvCKjOHemYA=";

  npmDeps = fetchNpmDeps {
    name = "${pname}-npm-deps-${version}";
    inherit src;
    hash = "sha256-W2X9g0LFIgkLbZBdr4OqodeN7U/h3nVfl3mKV9dsZTg=";
  };

  nativeBuildInputs = [
    pkg-config

    cargo-tauri.hook

    nodejs
    npmHooks.npmConfigHook
  ];

  buildInputs = [
    glib
    gtk3
    gtk4
    webkitgtk_4_1
    libsoup_3
    alsa-lib
  ];

  preBuild = ''
    # using sass-embedded fails at executing node_modules/sass-embedded-linux-x64/dart-sass/src/dart
    rm -r node_modules/sass-embedded*
  '';

  inherit cargoRoot;
  buildAndTestSubdir = cargoRoot;

  meta = {
    description = "A work-in-progress overlay application for launching various applications and games directly into a VR desktop environment";
    homepage = "https://github.com/olekolek1000/wayvr-dashboard";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "wayvr_dashboard";
  };
}
