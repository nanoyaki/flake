{
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs-slim,
  pnpm,
  pnpmConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sableclient-tauri-plugin-livekit-mobile";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "SableClient";
    repo = "tauri-plugin-livekit-mobile";
    rev = "v${finalAttrs.version}";
    hash = "sha256-SX5pEDBfpZpXBQsGx24oIP+d5P7kh3IqJGIX0nKRWcc=";
  };

  nativeBuildInputs = [
    nodejs-slim
    pnpmConfigHook
    pnpm
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-cocuFyA7p1m82wnVBSDX2sKHTyj81+iW854Z1WWDQrI=";
  };

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r package.json dist-js $out/
    runHook postInstall
  '';
})
