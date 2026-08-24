{
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs-slim,
  pnpm,
  pnpmConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sableclient-matrixrtc";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "SableClient";
    repo = "matrix-rtc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-H1iCb5IcgBMwt1v2vtiI2Ke9WaMGYXWEtKniks0Ob10=";
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
    hash = "sha256-g2J6XOLGitd1OK5g0mlkvUO9OBC7CBB7IB9WnuiY+dM=";
  };

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r package.json dist $out/
    runHook postInstall
  '';
})
