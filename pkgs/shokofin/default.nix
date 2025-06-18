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
    homepage = "https://github.com/ShokoAnime/Shokofin";
    changelog = "https://github.com/ShokoAnime/Shokofin/releases/tag/v${finalAttrs.version}";
    description = "Shoko anime Jellyfin integration plugin";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.nanoyaki ];
    inherit (dotnet-sdk_8.meta) platforms;
  };
})
