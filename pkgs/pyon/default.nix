{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "pyon";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "nanoyaki";
    repo = "pyon";
    rev = "v${version}";
    hash = "sha256-SgMYeWSQP3hk6t5jBHP2lIPe3ig7PFEhY2KnIHKM76s=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-uOY5vRzQ2MVLdgdpDkbLdMTScWxVyzq57v3WQJGFQAM=";

  meta = {
    description = "Print ASCII and braille bunnies to your terminal";
    homepage = "https://github.com/nanoyaki/pyon";
    license = lib.licenses.mit;
    mainProgram = "pyon";
  };
}
