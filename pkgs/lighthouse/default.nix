{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  dbus,
}:

rustPlatform.buildRustPackage {
  name = "lighthouse";

  src = fetchFromGitHub {
    owner = "ShayBox";
    repo = "Lighthouse";
    rev = "1.2.0";
    hash = "sha256-uJ8U4knNKAliHjxP0JnV1lSCEsB6OHyYSbb5aWboYV4=";
  };

  nativeBuildInputs = [
    pkg-config
    dbus
  ];

  buildInputs = [
    dbus
  ];

  cargoHash = "sha256-oRE6OGG4jCr1GdrRBAfadoYbjS3mYTXPCqlZvqHh3x8=";

  meta = {
    description = "Virtual reality basestation power management in Rust";
    homepage = "https://github.com/ShayBox/Lighthouse";
    license = lib.licenses.mit;
    mainProgram = "lighthouse";
    platforms = lib.platforms.x86_64;
  };
}
