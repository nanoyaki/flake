{
  lib,
  lib',
  config,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkIf
    optionalString
    mapAttrs'
    nameValuePair
    map
    attrNames
    attrValues
    concatStringsSep
    ;
  inherit (lib'.options)
    mkFalseOption
    mkDefault
    mkPathOption
    mkStrOption
    mkSubmoduleOption
    mkAttrsOf
    mkIntOption
    ;

  cfg = config.config'.mtls;

  dirCfg = {
    mode = "750";
    user = "mtls";
    group = "mtls";
  };

  caConfig = (pkgs.formats.ini { }).generate "ca.conf" {
    ca.default_ca = "CA_default";
    CA_default = {
      dir = cfg.dataDir;
      database = "${cfg.dataDir}/index.txt";
      crlnumber = "${cfg.dataDir}/crlnumber";
      new_certs_dir = "${cfg.dataDir}/newcerts";
      serial = "${cfg.dataDir}/serial";
      default_crl_days = "30";
      policy = "policy_any";
    };
    policy_any.commonName = "supplied";
  };

  crlUpdateDeps = map (name: "mtls-client-setup-${name}.service") (attrNames cfg.clients);
in

{
  options.config'.mtls = {
    enable = mkFalseOption;
    dataDir = mkDefault "/var/lib/mtls" mkPathOption;
    # Requires Gr33nbl00d/caddy-revocation-validator
    caddySnippet = mkDefault ''
      tls ${optionalString config.services.acme.enable "/var/lib/acme/${config.config'.caddy.baseDomain}/cert.pem /var/lib/acme/${config.config'.caddy.baseDomain}/key.pem"} {
        client_auth {
          mode require_and_verify
          trusted_ca_cert_file ${cfg.dataDir}/ca.crt
          verifier revocation {
            mode crl_only
            crl_config {
              crl_files ${cfg.dataDir}
              update_interval 30m
              trusted_signature_cert_file ${cfg.dataDir}/ca.crt
            }
          }
        }
      }
    '' mkStrOption;

    clients = mkAttrsOf (
      mkSubmoduleOption (
        { name, ... }:
        {
          options = {
            basePath = mkDefault "${cfg.dataDir}/clients/${name}" mkPathOption;
            daysValid = mkDefault 3650 mkIntOption;
            isRevoked = mkFalseOption;
          };
        }
      )
    );
  };

  config = mkIf cfg.enable {
    users.users.mtls = {
      home = cfg.dataDir;
      homeMode = "750";
      group = "mtls";
      isSystemUser = true;
    };

    users.groups.mtls = { };

    systemd.tmpfiles.settings.mtls = {
      "${cfg.dataDir}/newcerts".d = dirCfg;
      "${cfg.dataDir}/clients".d = dirCfg;
    }
    // mapAttrs' (_: client: nameValuePair client.basePath { d = dirCfg; }) cfg.clients;

    systemd.services = {
      mtls-setup = {
        wantedBy = [ "multi-user.target" ];

        path = [
          pkgs.openssl
          pkgs.coreutils
        ];
        script = ''
          openssl genpkey -algorithm ED25519 -out ca.key
          openssl req -x509 -new -key ca.key -out ca.crt -days 3650 \
            -subj "/CN=mTLS Client CA"

          touch index.txt
          echo 01 > crlnumber
          echo 01 > serial

          openssl ca -gencrl -out ca.crl \
            -keyfile ca.key -cert ca.crt \
            -config ${caConfig}

          cat ca.crt ca.crl > ca.pem
        '';

        unitConfig.ConditionPathExists = [
          "!${cfg.dataDir}/ca.key"
          "!${cfg.dataDir}/ca.crt"
          "!${cfg.dataDir}/ca.crl"
          "!${cfg.dataDir}/ca.pem"
        ];
        serviceConfig = {
          User = "mtls";
          Group = "mtls";
          Type = "oneshot";
          WorkingDirectory = cfg.dataDir;
        };
      };

      mtls-crl-update = {
        wantedBy = [ "multi-user.target" ];
        wants = crlUpdateDeps;
        after = crlUpdateDeps;

        path = with pkgs; [
          openssl
          coreutils
          gnused
        ];
        script = ''
          ${concatStringsSep "\n" (
            map (client: ''
              if [ -f "${client.basePath}/client.crt" ];
              then
                SERIAL=$(openssl x509 -in "${client.basePath}/client.crt" -serial -noout | cut -d= -f2)
                ${optionalString client.isRevoked ''
                  grep -q "$SERIAL" index.txt \
                    || echo "R	$(date -d '+10 years' '+%y%m%d%H%M%SZ')	$(date '+%y%m%d%H%M%SZ')	$SERIAL	unknown	/CN=${client.name}" \
                    >> index.txt
                ''}
                ${optionalString (!client.isRevoked) ''
                  sed -i "/^R.*$SERIAL/d" index.txt
                ''}
              fi
            '') (attrValues cfg.clients)
          )}

          openssl ca -gencrl -out ca.crl \
            -keyfile ca.key -cert ca.crt \
            -config ${caConfig}

          cat ca.crt ca.crl > ca.pem
        '';

        serviceConfig = {
          User = "mtls";
          Group = "mtls";
          Type = "oneshot";
          WorkingDirectory = cfg.dataDir;
        };
      };
    }
    // mapAttrs' (
      name: client:
      nameValuePair "mtls-client-setup-${name}" {
        wantedBy = [ "multi-user.target" ];
        wants = [ "mtls-setup.service" ];
        after = [ "mtls-setup.service" ];

        path = [
          pkgs.openssl
          pkgs.util-linux
        ];
        script = ''
          openssl genpkey -algorithm ED25519 \
            -out client.key

          openssl req -new \
            -key client.key \
            -out client.csr \
            -subj "/CN=${name}"

          exec 200> '${cfg.dataDir}/.ca.lock'
          flock -x 200

          openssl ca -batch \
            -in client.csr \
            -out client.crt \
            -days ${toString client.daysValid} \
            -keyfile '${cfg.dataDir}/ca.key' \
            -cert '${cfg.dataDir}/ca.crt' \
            -config ${caConfig}

          flock -u 200

          openssl pkcs12 -export -passout pass: \
            -inkey client.key \
            -in client.crt \
            -certfile '${cfg.dataDir}/ca.crt' \
            -out client.p12
        '';

        unitConfig.ConditionPathExists = [
          "${cfg.dataDir}/ca.key"
          "${cfg.dataDir}/ca.crt"
        ]
        ++ map (type: "!${client.basePath}/client.${type}") [
          "key"
          "csr"
          "crt"
          "p12"
        ];
        serviceConfig = {
          User = "mtls";
          Group = "mtls";
          Type = "oneshot";
          WorkingDirectory = client.basePath;
        };
      }
    ) cfg.clients;
  };
}
