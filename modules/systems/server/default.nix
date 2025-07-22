{
  imports = [
    ./deployment.nix
    ./norgb.nix
  ];

  config'.systemType = "server";
}
