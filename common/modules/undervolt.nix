{pkgs, ...}:
pkgs.writeShellScriptBin "unbervolt" ''
  python3="${pkgs.python3}/bin/python3"

  # TODO: Add nix packaging for the python script
  python3 $HOME/git-repos/Ryzen-5800x3d-linux-undervolting/ruv.py -c 8 -o -30
''
