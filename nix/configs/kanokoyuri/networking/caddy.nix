{
  flake.nixosModules.kanokoyuri-caddy =
    _:

    {
      services.caddy = {
        enable = true;
        email = "contact@nanoyaki.space";

        extraConfig = ''
          (tailnet-only) {
            @public not remote_ip 100.64.0.0/24 10.0.0.0/24 127.0.0.1/32 ::1/32

            handle @public {
              error 404
            }
          }
        '';

        virtualHosts."*.hanakretzer.de".extraConfig = ''
          error 404
        '';
      };

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
    };
}
