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

  useFetchCargoVendor = true;
  cargoHash = "sha256-YJgtkrDs7cBpjux0SE6TTXcduZRC+8+4SMMiCXYeCYI=";

  meta = {
    description = "Virtual reality basestation power management in Rust";
    homepage = "https://github.com/ShayBox/Lighthouse";
    license = lib.licenses.mit;
    mainProgram = "lighthouse";
    platforms = lib.platforms.x86_64;
  };
}
