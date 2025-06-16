{
  buildDotnetModule,
  dotnet-sdk_8,
  dotnet-aspnetcore_8,
  lib,
  nix-update-script,

  _sources,
}:
buildDotnetModule (finalAttrs: {
  inherit (_sources.shokofin) pname version src;

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
