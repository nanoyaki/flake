{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "python-modernize";
  version = "f06b20ad4728267ebcacb96075118529541697cd";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "PyCQA";
    repo = "modernize";
    rev = version;
    hash = "sha256-5GKIo3FjgM+8Ntf7OiBkR/JVvBq5+LFPtytmN5g4wwc=";
  };

  dependencies = with python3Packages; [
    fissix
    flit-core
  ];

  meta = {
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
  };
}
