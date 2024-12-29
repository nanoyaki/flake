{
  lib,
  rustPlatform,
  fetchgit,
  pkg-config,
  nodejs_22,
  dotnet-sdk_8,
  cargo-about,
}:

rustPlatform.buildRustPackage rec {
  pname = "alcom";
  version = "0.1.17";

  src = fetchgit {
    url = "https://github.com/vrc-get/vrc-get.git";
    rev = "gui-v${version}";
    hash = "sha256-ph9dJhm4DbI6/we/HD4T1LOafaWylhHoNT+zaYgl4f8=";
  };

  sourceRoot = "./vrc-get-gui";

  nativeBuildInputs = [
    pkg-config
    nodejs_22
    dotnet-sdk_8
    cargo-about
  ];

  buildInputs = [
    nodejs_22
  ];

  cargoHash = lib.fakeHash;

  meta = {
    license = lib.licenses.mit;
  };
}
