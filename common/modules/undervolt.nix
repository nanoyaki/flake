{
  username,
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "undervolt" ''
  # TODO: Add nix packaging for the python script
  sudo ${pkgs.python3}/bin/python3 /home/${username}/git-repos/Ryzen-5800x3d-linux-undervolting/ruv.py -c 8 -o -30
''
