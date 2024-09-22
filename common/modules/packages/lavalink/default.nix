{
  lib,
  stdenv,
  makeWrapper,
  pkg-config,
  systemd,
  zulu17,
  fetchurl,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "Lavalink";
  version = "4.0.8";

  src = fetchurl {
    url = "https://github.com/lavalink-devs/${finalAttrs.pname}/releases/download/${finalAttrs.version}/Lavalink.jar";
    hash = "sha256-G4a9ltPq/L0vcazTQjStTlOOtwrBi37bYUNQHy5CV9Y=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    systemd
  ];

  dontUnpack = true;

  postFixup = ''
    makeWrapper ${lib.getExe zulu17} $out/bin/lavalink \
      --add-flags "-jar $src"
  '';

  meta = with lib; {
    description = "A standalone audio sending node based on Lavaplayer and Koe";
    longDescription = ''
      A standalone audio sending node based on Lavaplayer and Koe. Allows for sending audio without it ever reaching any of your shards.

      Being used in production by FredBoat, Dyno, LewdBot, and more.
    '';
    homepage = "https://lavalink.dev/";
    changelog = "https://github.com/lavalink-devs/Lavalink/releases/tag/${finalAttrs.version}";
    license = licenses.mit;
    maintainers = with maintainers; [nanoyaki];
    mainProgram = "lavalink";
    platforms = zulu17.meta.platforms;
  };
})
