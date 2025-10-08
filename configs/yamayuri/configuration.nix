_:

{
  environment.systemPackages = [
    # is brokey :(
    # pkgs.libraspberrypi
  ];

  config'.yubikey = {
    enable = true;
    yuri.enable = true;
  };
}
