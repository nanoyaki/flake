{
  lib,
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
      chart = true;
      version = 4;
      inherit metric;
    };
  };

  sortCategories =
    categories:
    let
      sortedNames = lib.toposort (a: b: categories.${a}.before == b) (lib.attrNames categories);
      categoryNames = sortedNames.result or (lib.attrNames categories);
    in
    lib.map (name: { ${name} = categories.${name}.layout; }) categoryNames;
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

            before = mkOption {
              type = types.nullOr types.str;
              default = null;
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
      allowedHosts = "theless.one";

      settings = {
        title = "Homepage";
        startUrl = "https://theless.one";
        theme = "dark";
        language = "en";
        logpath = "/var/log/homepage/homepage.log";
        disableUpdateCheck = true;
        target = "_blank";

        background = {
          image = "https://homepage-images.theless.one/active.webp";
          blur = "xs";
          saturate = 50;
          brightness = 50;
          opacity = 50;
        };

        layout = [
          {
            Glances = {
              header = false;
              style = "row";
              columns = 3;
            };
          }
        ] ++ (sortCategories cfg.categories);

        headerStyle = "clean";
        statusStyle = "dot";
        hideVersion = "true";
      };

      services =
        [
          {
            Glances = [
              (mkGlancesWidget "CPU Usage" "cpu")
              (mkGlancesWidget "CPU Temp" "sensor:Package id 0")
              (mkGlancesWidget "Memory Usage" "memory")
              (mkGlancesWidget "Storage Usage" "fs:/")
              (mkGlancesWidget "Disk I/O" "disk:nvme0n1")
              (mkGlancesWidget "Network Usage" "network:enp6s0")
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

    services.caddy-easify.reverseProxies."theless.one" = {
      port = config.services.homepage-dashboard.listenPort;
      userEnvVar = "shared";
    };

    systemd.tmpfiles.settings."10-homepage"."/var/log/homepage".d = {
      user = "root";
      group = "wheel";
      mode = "0755";
    };
  };
}
