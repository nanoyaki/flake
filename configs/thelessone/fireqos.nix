{ pkgs, ... }:

{
  home-manager.users.root.home.packages = [ pkgs.firehol ];

  services.fireqos = {
    enable = true;
    config = ''
      interface enp6s0 world-in input rate 250mbit
    '';
  };
}
