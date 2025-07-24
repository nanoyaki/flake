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
    systemd.services.ensure-id-file = {
      wantedBy = [ "multi-user.target" ];

      path = [ pkgs.openssh ];

      script = ''
        if [[ ! -e "${cfg.defaultId}" ]]
        then
          ssh-keygen \
            -t ed25519 \
            -N "" \
            -C "" \
            -f ${cfg.defaultId}
        else
          exit 0
        fi
      '';

      serviceConfig = {
        Type = "oneshot";
        Restart = "no";
      };
    };

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
