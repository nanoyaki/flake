{
  lib,
  rustPlatform,
  addDriverRunpath,
  atkmm,
  cargo-tauri,
  cef-binary,
  dbus,
  desktop-file-utils,
  fetchFromGitHub,
  fetchPnpmDeps,
  gtk3,
  glib,
  glib-networking,
  gst_all_1,
  libGL,
  libpulseaudio,
  libxkbcommon,
  nix-update-script,
  nodejs-slim_24,
  pipewire,
  pkg-config,
  pnpm_10,
  pnpmConfigHook,
  stdenv,
  symlinkJoin,
  webkitgtk_4_1,
  writeText,
  xdg-utils,
  libayatana-appindicator,
  wrapGAppsHook3,
  runtime ? "cef",
}:

assert lib.assertOneOf "runtime" runtime [
  "cef"
  "wry"
];

let
  isCef = runtime == "cef";
  isWry = runtime == "wry";
  nodejs-slim = nodejs-slim_24;
  pnpm = pnpm_10.override { inherit nodejs-slim; };
  cef = cef-binary.override {
    version = "150.0.14";
    gitRevision = "7c1aa68";
    chromiumVersion = "150.0.7871.129";
    srcHashes = {
      x86_64-linux = "sha256-QO9hPkVcrNB6p8gfQl76qLb3frg/E8wo1HDuuk5h+Y8=";
      aarch64-linux = "sha256-tA4hWg9G/UDQSxXUuDO+IRjvc8Qx1cEdGOtiXg3ktk0=";
    };
  };
  # fake archive.json to prevent automatically downloading CEF here
  # as per https://github.com/tauri-apps/cef-rs/issues/426
  fakeArchiveJson = writeText "archive.json" (
    builtins.toJSON {
      name = cef.src.name;
      sha1 = "";
      type = "minimal";
    }
  );
  cefFlat = symlinkJoin {
    name = "cef-${cef.version}-flat";
    paths = [
      "${cef}/${cef.buildType}"
      "${cef}/Resources"
    ];
    postBuild = ''
      ln -s ${cef}/libcef_dll "$out/"
      ln -s ${fakeArchiveJson} "$out/archive.json"
    '';
  };
  # these are maintained by sable; they would get built during pnpm install
  # as executing their buildscripts is not possible in fetchPnpmDeps, we build them ourselves
  matrixrtc = import ./_sableclient-matrixrtc.nix {
    inherit
      stdenv
      fetchFromGitHub
      nodejs-slim
      pnpm
      fetchPnpmDeps
      pnpmConfigHook
      ;
  };
  tauri-plugin-livekit-mobile = import ./_sableclient-tauri-plugin-livekit-mobile.nix {
    inherit
      stdenv
      fetchFromGitHub
      nodejs-slim
      pnpm
      fetchPnpmDeps
      pnpmConfigHook
      ;
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "sable-desktop";
  version = "1.21.0";

  src = fetchFromGitHub {
    owner = "SableClient";
    repo = "Sable";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vYoKNflV4vdJpgYVxYCxAQhvqDh1Qf+7qgIFHxriTTU=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-tzIU/5DQ4SpLABKOt6/Z2aD2d6nVt+MJvY7vHHnO4No=";
  };

  env = {
    VITE_BUILD_HASH = finalAttrs.src.rev;
    VITE_IS_RELEASE_TAG = "true";
    NODE_OPTIONS = "--max-old-space-size=4096";
  }
  // lib.optionalAttrs isCef { CEF_PATH = "${cefFlat}"; };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  cargoHash = "sha256-E38C5pttAidLLRLI3+UPYJqQbBhFsMI1nnYu06gvSF8=";
  cargoDepsName = finalAttrs.pname;

  tauriBuildFlags = "--no-sign";
  buildNoDefaultFeatures = true;
  buildFeatures = [
    runtime
    "custom-protocol"
  ];

  postPatch = ''
    substituteInPlace src-tauri/src/lib.rs \
      --replace-fail "                use tauri_plugin_deep_link::DeepLinkExt;" "" \
      --replace-fail "                app.deep_link().register_all()?;" ""
  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    dbus.dev
    desktop-file-utils
    nodejs-slim
    pkg-config
    pnpm
    pnpmConfigHook
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libayatana-appindicator
    # always needed at least until https://github.com/tauri-apps/tauri/pull/15068 gets merged
    webkitgtk_4_1
  ]
  ++ lib.optionals isWry [
    atkmm
    glib
    glib-networking
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];

  preBuild = ''
    cp -r ${matrixrtc}/dist node_modules/@sableclient/matrixrtc/
    chmod -R u+w node_modules/@sableclient/matrixrtc
    cp -r ${tauri-plugin-livekit-mobile}/dist-js node_modules/@sableclient/tauri-plugin-livekit-mobile/
    chmod -R u+w node_modules/@sableclient/tauri-plugin-livekit-mobile
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}"
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libayatana-appindicator
          libGL
          libxkbcommon
          libpulseaudio
          pipewire
        ]
      }:${addDriverRunpath.driverLink}/lib"
    )
  '';

  postFixup = ''
    desktop-file-edit \
      --set-key="Categories" --set-value="Network;InstantMessaging;Chat;" \
      --set-key="Exec" --set-value="sable %u" \
      "$out/share/applications/Sable.desktop"
  ''
  + lib.optionalString isCef ''
    ln -s ${cef}/${cef.buildType}/* ${cef}/Resources/* "$out/bin/"
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "An almost stable Matrix client";
    homepage = "https://github.com/SableClient/Sable";
    changelog = "https://github.com/SableClient/Sable/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    # maintainers = with lib.maintainers; [
    #   fugi
    #   lunar-seal
    #   toasteruwu
    # ];
    license = [
      lib.licenses.agpl3Only
    ];
    mainProgram = "sable";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
