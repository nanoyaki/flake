{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  dbus,
}:

rustPlatform.buildRustPackage rec {
  pname = "lighthouse";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "ShayBox";
    repo = "Lighthouse";
    rev = version;
    hash = "sha256-uJ8U4knNKAliHjxP0JnV1lSCEsB6OHyYSbb5aWboYV4=";
  };

  nativeBuildInputs = [
    pkg-config
    dbus
  ];

  buildInputs = [
    dbus
  ];

  cargoHash = "sha256-9tJ8TB0oHlriCKFTBhuKQS+Y3oz8QK9/GGLiekoWPa8=";

  meta = {
    description = "Virtual reality basestation power management in Rust";
    homepage = "https://github.com/ShayBox/Lighthouse";
    license = lib.licenses.mit;
    mainProgram = "lighthouse";
    platforms = lib.platforms.x86_64;
  };
}
