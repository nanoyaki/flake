{ pkgs, ... }:

{
  home-manager.users.root.home.packages = [ pkgs.firehol ];

  services.fireqos = {
    enable = true;
    config = ''
      interface enp6s0 world-in input rate 200mbit
      interface enp6s0 world-out output rate 20mbit
        class web
          match tcp ports 80,443

      interface tailscale0 vpn-out output rate 20mbit
    '';
  };
}
