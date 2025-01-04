{
  lib,
  pkgs,
  config,
  ...
}:

let
  mullvad = lib.getExe' pkgs.mullvad "mullvad";
  yes = lib.getExe' pkgs.coreutils "yes";

  # To bypass 'set -e'
  ExecStart = lib.getExe (
    pkgs.writeShellScriptBin "mullvad-configuration-start" ''
      ${yes} | ${mullvad} factory-reset

      ${mullvad} account login $(cat ${config.sec."mullvad/account".path})

      ${mullvad} custom-list new Reliable
      ${mullvad} custom-list edit add Reliable at vie
      ${mullvad} custom-list edit add Reliable de fra
      ${mullvad} relay set custom-list Reliable

      ${mullvad} auto-connect set on
      ${mullvad} lan set allow
      ${mullvad} dns set custom 1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4

      ${mullvad} connect
    ''
  );
in

{
  sec."mullvad/account" = { };
  services.mullvad-vpn.enable = true;
  systemd.services =
    {
      mullvad-configuration = {
        description = "Mullvad configuration service";

        serviceConfig = {
          inherit ExecStart;
          Restart = "on-failure";
          Type = "simple";
        };

        after = [ "mullvad-daemon.service" ];
        wantedBy = [ "mullvad-daemon.service" ];
        requires = [ "mullvad-daemon.service" ];
      };
    }
    // (lib.mapAttrs' (
      domain: _:
      lib.nameValuePair "namecheap-dynamic-dns-${domain}" {
        wantedBy = [ "mullvad-configuration.service" ];
      }
    ) config.services.namecheapDynDns.domains);
}
