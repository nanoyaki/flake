{
  self,
  pkgs,
  inputs',
  config,
  ...
}:

{
  config' = {
    localization = {
      timezone = "Europe/Vienna";
      language = "de_AT";
      locale = "de_AT.UTF-8";
    };

    firefox.enable = true;
    theming.enable = true;
    steam.enable = true;
  };

  sops.secrets = {
    "uptime-kuma/user" = { };
    "uptime-kuma/password" = { };
  };

  sops.templates."rbm.env".file = (pkgs.formats.keyValue { }).generate "rbm.env" {
    UPTIME_KUMA_URL = "https://status.nanoyaki.space/";
    UPTIME_KUMA_USER = config.sops.placeholder."uptime-kuma/user";
    UPTIME_KUMA_PASSWORD = config.sops.placeholder."uptime-kuma/password";
  };

  environment.systemPackages = with pkgs; [
    vesktop
    vscodium
    tmux
    prismlauncher

    (writeShellApplication {
      name = "rbm";
      runtimeInputs = [
        nix-fast-build
        inputs'.rebuild-maintenance.packages.rebuild-maintenance
      ];
      text = ''
        set -eo pipefail

        if [[ $EUID -ne 0 ]]; then
          echo "Script requires root priviledges."
          exit 1
        fi

        nix-fast-build --eval-workers 4 --out-link result \
          -f ${config.config'.nix.flakeDir}#nixosConfigurations."$(hostname)".config.system.build.toplevel

        set -o allexport
        # shellcheck source=/dev/null
        source ${config.sops.templates."rbm.env".path}
        set +o allexport

        echo "Initializing maintenance..."
        MAINTENANCE_ID="$(rebuild_maintenance -i)"

        echo "Deleting home-manager backups..."
        find ${config.users.users.${config.config'.mainUserName}.home} -name "*.home-bac" -delete

        echo "Running switch-to-configuration switch..."
        ./result-/bin/switch-to-configuration switch

        echo "Adding system profile..."
        NEWEST_GEN="$(nix-env --profile /nix/var/nix/profiles/system --list-generations | awk '{ print $1 }' | tail -n -1)";
        BUILT_GEN="$((NEWEST_GEN + 1))"

        ln -s "$(readlink -f ./result-)" /nix/var/nix/profiles/system-$BUILT_GEN-link

        echo "Switching system profile..."
        nix-env --profile /nix/var/nix/profiles/system --switch-generation $BUILT_GEN

        echo "Deleting result link..."
        rm -rf "./result-"

        rebuild_maintenance -e "$MAINTENANCE_ID"

        echo -e 'Done. \033[38;5;219m\U2665\033[0m'
      '';
    })
  ];

  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both";
  };

  security.sudo.extraRules = [
    {
      users = [ config.config'.mainUserName ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  services.iperf3 = {
    enable = true;
    openFirewall = true;
  };

  # for deployment
  environment.etc."systems/thelessnas".source =
    self.nixosConfigurations.thelessnas.config.system.build.toplevel;

  systemd.tmpfiles.settings."10-restic-backups"."/mnt/raid/backups".d = {
    mode = "0700";
    user = "root";
    group = "wheel";
  };
}
