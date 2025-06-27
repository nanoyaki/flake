{
  lib,
  beetsPackages,
  fetchFromGitHub,
  python3Packages,
  nix-update-script,
}:

let
  inherit (beetsPackages) beets-minimal;
in

python3Packages.buildPythonApplication rec {
  pname = "beets-copyartifacts";
  version = "6bda199a8f5710b2265ce66cff8f2d3c6f09f6dc";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "martinkirch";
    repo = "drop2beets";
    rev = version;
    hash = "sha256-YvtdAjRbEh9tb60gp6Lh70QSISPn6uZNWi09EF0Dkwg=";
  };

  patches = [
    ./watchdog-version.patch
  ];

  nativeBuildInputs = [
    beets-minimal
    python3Packages.poetry-core
  ];
  dependencies = [ python3Packages.watchdog ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Beets plug-in that imports singles as soon as they are dropped in a folder.";
    homepage = "https://github.com/martinkirch/drop2beets/";
    license = lib.licenses.wtfpl;
    maintainers = with lib.maintainers; [ nanoyaki ];
    inherit (beets-minimal.meta) platforms;
  };
}
