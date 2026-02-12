{
  flake.nixosModules.vopono =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    let
      inherit (lib) getExe mkDefault;
    in

    {
      environment.systemPackages = with pkgs; [
        vopono
        wireguard-tools
      ];

      boot.kernelModules = [
        "tun"
        "wireguard"
      ];

      systemd.services.voponod = {
        description = "Vopono root daemon";
        after = [ "network.target" ];
        wantedBy = [ "mutli-user.target" ];

        path =
          (with pkgs; [
            wireguard-tools
            iproute2
            procps
            openvpn
          ])
          ++ lib.optional config.networking.nftables.enable pkgs.nftables
          ++ lib.optional (!config.networking.nftables.enable) pkgs.iptables;

        environment = mkDefault {
          RUST_LOG = "info";
        };

        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = "2s";
          ExecStart = "${getExe pkgs.vopono} daemon";
        };
      };
    };
}
