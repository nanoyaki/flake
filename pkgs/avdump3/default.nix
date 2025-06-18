{
  lib,
  avdump3,
  unzip,
  makeWrapper,
  dotnet-runtime,
  zlib,

  _sources,
}:

avdump3.overrideAttrs (oldAttrs: {
  inherit (_sources.avdump3) pname version src;

  nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
    unzip
    makeWrapper
  ];

  unpackPhase =
    (oldAttrs.unpackPhase or "")
    + ''
      unzip $src
    '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/avdump3 $out/bin $out/lib

    mv AVDump3NativeLib-linux-x64.so $out/lib/AVDump3NativeLib.so
    mv MediaInfo-linux-x64.so $out/lib/MediaInfo.so
    mv * $out/share/avdump3

    makeWrapper ${dotnet-runtime}/bin/dotnet $out/bin/avdump3 \
      --prefix LD_LIBRARY_PATH : "${lib.makeBinPath [ zlib ]}:$out/lib" \
      --add-flags "$out/share/avdump3/AVDump3CL.dll"

    chmod +x $out/bin/avdump3
    runHook postInstall
  '';
})
