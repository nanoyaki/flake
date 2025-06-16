{
  buildDotnetModule,
  fetchFromGitHub,
  dotnet-sdk_8,
  dotnet-aspnetcore_8,
  lib,
  nix-update-script,
}:
buildDotnetModule (finalAttrs: {
  pname = "shokofin";
  version = "5.0.3";

  src = fetchFromGitHub {
    owner = "ShokoAnime";
    repo = "Shokofin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Zt4h3IvJ32dqac8Jr2ZZBJ2nopdk6+dlmMi+wvCCihE=";
  };

  dotnet-sdk = dotnet-sdk_8;
  dotnet-runtime = dotnet-aspnetcore_8;

  nugetDeps = ./deps.json;
  projectFile = "Shokofin/Shokofin.csproj";
  dotnetBuildFlags = "/p:InformationalVersion=\"channel=stable\"";

  executables = [ ];

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/ShokoAnime/ShokoServer";
    changelog = "https://github.com/ShokoAnime/ShokoServer/releases/tag/v${finalAttrs.version}";
    description = "Backend for the Shoko anime management system";
    license = lib.licenses.mit;
    mainProgram = "Shoko.CLI";
    maintainers = [ lib.maintainers.nanoyaki ];
    inherit (dotnet-sdk_8.meta) platforms;
  };
})
