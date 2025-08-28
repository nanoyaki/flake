{
  runCommand,
  python3,
}:

runCommand "${python3.pkgs.kaleido.pname}-tests" {
  nativeBuildInputs = [
    (python3.withPackages (
      pyPkgs: with pyPkgs; [
        kaleido
        plotly
        numpy
      ]
    ))

  ];
} "python3 ${./kaleido-test.py}"
