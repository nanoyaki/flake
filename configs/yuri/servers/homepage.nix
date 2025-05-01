{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) types mkOption;

  cfg = config.services.homepage-easify;

  mkGlancesWidget = name: metric: {
    ${name}.widget = {
      url = "http://localhost:${toString config.services.glances.port}";
      type = "glances";
      chart = false;
      version = 4;
      inherit metric;
    };
  };
in

{
  options.services.homepage-easify = {
    categories = mkOption {
      default = { };
      type = types.attrsOf (
        types.submodule {
          options = {
            services = mkOption {
              type = types.attrsOf (
                types.submodule {
                  options = {
                    description = mkOption { type = types.str; };
                    href = mkOption { type = types.str; };
                    siteMonitor = mkOption { type = types.str; };
                    icon = mkOption { type = types.str; };
                  };
                }
              );
            };
            layout = {
              header = mkOption {
                type = types.bool;
                default = true;
              };
              style = mkOption {
                type = types.enum [
                  "row"
                  "column"
                ];
                default = "column";
              };
              columns = mkOption {
                type = types.nullOr types.int;
                default = null;
              };
            };
          };
        }
      );
    };
  };

  config = {
    assertions = [
      {
        assertion =
          (lib.filterAttrs (
            _: category: category.layout.style == "row" && category.layout.columns == null
          ) cfg.categories) == { };
        message = "Columns must not be null when using the row layout style";
      }
    ];

    services.homepage-dashboard = {
      enable = true;
      allowedHosts = "home.local";

      settings = {
        title = "Homepage";
        startUrl = "http://home.local";
        theme = "dark";
        language = "de";
        logpath = "/var/log/homepage/homepage.log";
        disableUpdateCheck = true;
        target = "_blank";

        background = {
          image = "${pkgs.fetchurl {
            url = "https://images.pexels.com/photos/2335126/pexels-photo-2335126.jpeg";
            hash = "sha256-WNiQ0ys8ERoKj7Pmm8ix3vy7uKF3+kqQgHt6ikSOrh8=";
          }}";
          blur = "sm";
          saturate = 50;
          brightness = 50;
          opacity = 50;
        };

        layout =
          [
            {
              Glances = {
                header = false;
                style = "row";
                columns = 4;
              };
            }
          ]
          ++ (lib.mapAttrsToList (categoryName: category: {
            ${categoryName} = category.layout;
          }) cfg.categories);

        headerStyle = "clean";
        statusStyle = "dot";
        hideVersion = "true";
      };

      services =
        [
          {
            Glances = [
              (mkGlancesWidget "Info" "info")
              (mkGlancesWidget "Speicherplatz" "fs:/")
              (mkGlancesWidget "CPU Temperatur" "sensor:Package id 0")
              (mkGlancesWidget "Netzwerk" "network:enp3s0")
            ];
          }
        ]
        ++ (lib.mapAttrsToList (categoryName: category: {
          ${categoryName} = lib.mapAttrsToList (serviceName: service: {
            ${serviceName} = service;
          }) category.services;
        }) cfg.categories);
    };

    services.glances.enable = true;

    systemd.tmpfiles.settings."10-homepage"."/var/log/homepage".d = {
      user = "root";
      group = "wheel";
      mode = "0755";
    };
  };
}
