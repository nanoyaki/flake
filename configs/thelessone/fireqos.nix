{ pkgs, ... }:

{
  home-manager.users.root.home.packages = [ pkgs.firehol ];

  services.fireqos = {
    enable = true;
    config = ''
      interface tailscale0 vpn-out output rate 100mbit
    '';
  };
}
