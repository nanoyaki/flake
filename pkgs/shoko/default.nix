{
  buildDotnetModule,
  dotnet-sdk_8,
  dotnet-aspnetcore_8,
  dotnet-runtime_6,
  nixosTests,
  lib,
  mediainfo,
  rhash,
  avdump3,
  replaceVars,
  nix-update-script,

  _sources,
}:

let
  # insecure dotnet 6 for avdump
  avdump = avdump3.override { dotnet-runtime = dotnet-runtime_6; };
in

buildDotnetModule (finalAttrs: {
  inherit (_sources.shoko) pname version src;

  patches = [ (replaceVars ./avdump.patch { avdump3 = lib.getExe avdump; }) ];

  dotnet-sdk = dotnet-sdk_8;
  dotnet-runtime = dotnet-aspnetcore_8;

  nugetDeps = ./deps.json;
  projectFile = "Shoko.CLI/Shoko.CLI.csproj";
  dotnetBuildFlags = "/p:InformationalVersion=\"channel=stable\"";

  executables = [ "Shoko.CLI" ];
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${mediainfo}/bin"
  ];
  runtimeDeps = [ rhash ];

  passthru = {
    updateScript = nix-update-script { };
    tests.shoko = nixosTests.shoko;
  };

  meta = {
    homepage = "https://github.com/ShokoAnime/ShokoServer";
    changelog = "https://github.com/ShokoAnime/ShokoServer/releases/tag/v${finalAttrs.version}";
    description = "Backend for the Shoko anime management system";
    license = lib.licenses.mit;
    mainProgram = "Shoko.CLI";
    # maintainers = [ lib.maintainers.diniamo ];
    inherit (dotnet-sdk_8.meta) platforms;
  };
})
