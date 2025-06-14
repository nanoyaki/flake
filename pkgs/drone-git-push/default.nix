{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  git,
  curl,
  openssh,
  perl,
  git-lfs,
}:

buildGoModule (finalAttrs: {
  pname = "drone-git-push";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "appleboy";
    repo = "drone-git-push";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fa47C4L0MpbLUGKo8sUMl3rCgrIgEG76Xp7hlYAju3E=";
  };

  patches = [
    ./home-from-env.patch
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  nativeCheckInputs = [
    git
  ];

  preCheck = ''
    git init
  '';

  vendorHash = "sha256-4vPJV2rHPvZS7Dv4CD/FAixcPCH+y9vEYne1YUKI8VQ=";

  postInstall = ''
    wrapProgram $out/bin/drone-git-push --prefix PATH : ${
      lib.makeBinPath [
        git
        curl
        openssh
        perl
        git-lfs
      ]
    }
  '';

  meta = {
    description = "Drone / Woodpecker plugin to push changes to a remote git repository.";
    homepage = "https://github.com/appleboy/drone-git-push";
    mainProgram = "drone-git-push";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nanoyaki ];
  };
})
