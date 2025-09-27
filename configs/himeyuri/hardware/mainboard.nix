{ pkgs, ... }:

let
  nct6775 = "8b76273cb2328ccea47d925147ddb6ab7acacd5ebee2f4fd1e814716d9470129";
  ryzen5 = "cc70b4fa373b641d7dd71c7b5d3778e5c242726d11113e4551d3ed64b48989dd";

  cpuGraph = "fccf9cb5-d8a9-4938-aa72-0b83694d2383";
  useSensor = "02ba5ea0-89cc-4085-808f-c3b1cc97963b";

  default = "0";

  configToml =
    ((pkgs.formats.toml { }).generate "config.toml" {
      devices = {
        ${ryzen5} = "AMD Ryzen 5 5600X 6-Core Processor";
        ${nct6775} = "nct6795";
      };

      device-settings.${nct6775}.fan2 = ''{ profile_uid = "${cpuGraph}" }'';

      profiles = [
        {
          uid = default;
          name = "Default Profile";
          p_type = "Default";
          function = default;
        }
        {
          uid = cpuGraph;
          name = "CPU graph";
          p_type = "Graph";
          speed_profile = [
            [
              20.0
              0
            ]
            [
              50.0
              10
            ]
            [
              65.0
              20
            ]
            [
              75.0
              40
            ]
            [
              85.0
              75
            ]
            [
              90.0
              100
            ]
            [
              100.0
              100
            ]
          ];
          temp_source = ''{ temp_name = "temp1", device_uid = "${ryzen5}" }'';
          function_uid = useSensor;
        }
      ];

      functions = [
        {
          uid = default;
          name = "Default Function";
          f_type = "Identity";
        }
        {
          uid = useSensor;
          name = "Use sensor";
          f_type = "Identity";
          duty_minimum = 2;
          duty_maximum = 100;
        }
      ];

      settings = {
        apply_on_boot = true;

        # liquidctl
        liquidctl_integration = true;
        hide_duplicate_devices = true;
        no_init = false;
        startup_delay = 2;

        thinkpad_full_speed = false;

        compress = false;
      };

      legacy690 = { };
    }).overrideAttrs
      (prevAttrs: {
        buildCommand = prevAttrs.buildCommand or "" + ''
          substituteInPlace $out \
            --replace-fail '"{' '{' \
            --replace-fail '\"' '"' \
            --replace-fail '}"' '}'
        '';
      });
in

{
  boot.kernelModules = [ "nct6775" ];

  programs.coolercontrol.enable = true;
  systemd.services.coolercontrold.restartTriggers = [ configToml ];
  environment.etc."coolercontrol/config.toml" = {
    source = configToml;
    mode = "0644";
    user = "root";
    group = "root";
  };
}
