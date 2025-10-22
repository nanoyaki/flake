{
  imports = [
    ./deployment.nix
    ./ssh.nix
  ];

  networking.useDHCP = true;
}
