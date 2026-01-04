{
  imports = [
    ./deployment.nix
    ./ssh.nix
    ./wireguard.nix
  ];

  networking.useDHCP = true;
}
