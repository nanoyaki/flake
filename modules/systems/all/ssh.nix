{
  lib',
  config,
  pkgs,
  ...
}:

let
  inherit (lib'.options) mkPathOption mkDefault;

  cfg = config.config'.ssh;
in

{
  options.config'.ssh.defaultId = mkDefault "${config.hm.home.homeDirectory}/.ssh/id_${config.networking.hostName}" mkPathOption;

  config = {
    sops.secrets.id_owned-material_pull = {
      sopsFile = ./secrets.yaml;
      path = "/etc/ssh/id_owned-material_pull";
    };
    environment.etc."ssh/id_owned-material_pull.pub".text = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOSUAgwaWY75NrPgYeqZR55lz3THlczUVhhK1mZOJt6N
    '';
    programs.ssh.knownHosts."git.theless.one".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkogFEPPOMfkRsBgyuHDQeWQMetWCZbkTpnfajTbu7t";

    systemd.services.ensure-id-file = {
      wantedBy = [ "multi-user.target" ];

      path = [ pkgs.openssh ];

      script = ''
        ssh-keygen \
          -t ed25519 \
          -N "" \
          -C "" \
          -f ${cfg.defaultId}
      '';

      unitConfig.ConditionPathExists = "!${cfg.defaultId}";
      serviceConfig = {
        Type = "oneshot";
        Restart = "no";
      };
    };

    programs.ssh.extraConfig = ''
      Host git.theless.one
        User git
        IdentityFile ${cfg.defaultId}
        IdentityFile /etc/ssh/id_owned-material_pull
    '';

    hm.programs.ssh = {
      enable = true;

      matchBlocks.git = {
        user = "git";
        host = "github.com codeberg.org gitlab.com git.theless.one";
        identityFile = cfg.defaultId;
      };

      extraConfig = ''
        IdentityFile ${cfg.defaultId}
      '';
    };
  };
}
