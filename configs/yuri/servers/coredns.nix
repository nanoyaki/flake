{
  networking.resolvconf.useLocalResolver = true;

  services.coredns = {
    enable = true;
    config = ''
      .:53 {
        bind 127.0.0.1 ::1 enp7s0

        errors
        log
        
        hosts {
          10.0.0.3 home.local
          fallthrough
        }

        template IN A home.local {
          answer "{{ .Name }} 60 IN A 10.0.0.3"
          fallthrough
        }

        template IN A nanoyaki.space {
          answer "{{ .Name }} 60 IN A 10.0.0.3"
          fallthrough
        }

        template IN AAAA nanoyaki.space {
          answer "{{ .Name }} 60 IN AAAA fd11:ad5:2cc6::1ac0:4dff:fea2:8521"
          fallthrough
        }

        cache 300

        forward . 1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4
      }

      .:53 {
        bind 10.100.0.1 fd50::1

        errors
        log

        hosts {
          10.100.0.1 nanoyaki.space
          fd50::1    nanoyaki.space
          fallthrough
        }

        template IN A nanoyaki.space {
          answer "{{ .Name }} 60 IN A 10.100.0.1"
          fallthrough
        }

        template IN AAAA nanoyaki.space {
          answer "{{ .Name }} 60 IN AAAA fd50::1"
          fallthrough
        }

        cache 300

        forward . 1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4
      }
    '';
  };

  networking.firewall.allowedUDPPorts = [ 53 ];
  networking.firewall.allowedTCPPorts = [ 53 ];
}
