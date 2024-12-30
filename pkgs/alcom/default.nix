{
  lib,
  stdenv,
  stdenvNoCC,
  rustPlatform,
  fetchFromGitHub,
  dotnet-sdk_8,
  cargo,
  rustc,
  cargo-tauri,
  cargo-about,
  pkg-config,
  nodePackages,
  libayatana-appindicator,
  gtk3,
  webkitgtk,
  libsoup,
  openssl,
}:

stdenv.mkDerivation rec {
  pname = "alcom";
  version = "1.0.0-rc.1";

  src = fetchFromGitHub {
    owner = "vrc-get";
    repo = "vrc-get";
    rev = "gui-v${version}";
    hash = "sha256-7oJ0eml11WYSKgGpeRvazJQ+k//5csl0u3M/yegPOlw=";
  };

  patches = [
    ./build.patch
  ];

  sourceRoot = "${src.name}/vrc-get-gui";

  postPatch = ''
    substituteInPlace $cargoDepsCopy/libappindicator-sys-*/src/lib.rs \
      --replace "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
  '';

  npm-deps = stdenvNoCC.mkDerivation {
    pname = "${pname}-npm-deps";
    inherit version src;

    sourceRoot = "${src.name}/vrc-get-gui";

    nativeBuildInputs = [
      nodePackages.npm
    ];

    installPhase = ''
      export HOME=$(mktemp -d)
      # use --ignore-scripts and --omit optional to avoid downloading binaries
      # use ci to avoid checking git deps

      mkdir -p $out
      cp $src/vrc-get-gui/package.json $out/package.json
      cp $src/vrc-get-gui/package-lock.json $out/package-lock.json
      cd $out

      npm ci --ignore-scripts
    '';

    dontFixup = true;
    outputHashMode = "recursive";
    outputHash = "sha256-DQo0AAQttE62oFpAfZiRNukJndqXy3KjuhrLsEvED3c=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };
  cargoRoot = "..";
  cargoHash = lib.fakeHash;

  nativeBuildInputs = [
    dotnet-sdk_8
    rustPlatform.cargoSetupHook
    cargo
    rustc
    cargo-tauri
    cargo-about
    nodePackages.npm
    pkg-config
  ];

  buildInputs = [
    gtk3
    libsoup
    libayatana-appindicator
    openssl
    webkitgtk
  ];

  preBuild = ''
    export HOME=$(mktemp -d)

    cp ${npm-deps}/node_modules . -r
    chmod -R +w node_modules

    cp $src/Cargo.lock .
    cargo tauri build -b deb
  '';

  preInstall = ''
    mv target/release/bundle/deb/*/data/usr/ $out
  '';

  meta = {
    description = "A fast open-source alternative of VRChat Creator Companion";
    mainProgram = "alcom";
    homepage = "https://vrc-get.anatawa12.com/en/alcom/";
    platforms = lib.platforms.linux;
    license = lib.licenses.mit;
  };
}
