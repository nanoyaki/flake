{
  lib,
  lib',
  config,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    mkEnableOption
    mkIf
    ;

  inherit (lib.lists) elemAt map toposort;
  inherit (lib.attrsets) attrNames mapAttrsToList filterAttrs;
  inherit (lib.strings) toInt optionalString;
  inherit (lib.versions) major;

  inherit (lib') mkEnabledOption;

  cfg = config.services.homepage-easify;

  subdomain = optionalString cfg.useSubdomain "${cfg.subdomain}.";
  slug = optionalString cfg.useDomainSlug "/${cfg.domainSlug}";
  inherit (config.services.caddy-easify) baseDomain;
  scheme = "http${optionalString config.services.caddy-easify.useHttps "s"}://";

  domain = "${scheme}${subdomain}${baseDomain}${slug}";

  sortCategories =
    categories:
    let
      sortedNames = toposort (a: b: categories.${a}.before == b) (attrNames categories);
      categoryNames = sortedNames.result or (attrNames categories);
    in
    map (name: { ${name} = categories.${name}.layout; }) categoryNames;
in

{
  options.services.homepage-easify = {
    enable = mkEnabledOption "homepage dashboard";

    useSubdomain = mkEnableOption "a subdomain for homepage dashboard";

    subdomain = mkOption {
      type = types.str;
      default = "homepage";
    };

    useDomainSlug = mkEnableOption "the domain slug for homepage dashboard";

    domainSlug = mkOption {
      type = types.str;
      default = "homepage";
    };

    glances = {
      widgets = mkOption {
        default = [
          { Info.metric = "info"; }
          { "Cpu usage".metric = "cpu"; }
          { "Disk usage".metric = "fs:/"; }
          { "Memory usage".metric = "memory"; }
        ];

        type = types.listOf (
          lib'.types.singleAttrOf (
            types.submodule {
              options = {
                metric = mkOption { type = types.str; };
                chart = mkEnableOption "the metric chart";
              };
            }
          )
        );
      };

      layout = {
        header = mkOption {
          type = types.bool;
          default = false;
        };

        style = mkOption {
          type = types.enum [
            "row"
            "column"
          ];
          default = "row";
        };

        columns = mkOption {
          type = types.int;
          default = 4;
        };
      };

      version = mkOption {
        type = types.int;
        default = toInt (major config.services.glances.package.version);
      };

      scheme = mkOption {
        type = types.enum [
          "http"
          "https"
        ];
        default = "http";
      };

      host = mkOption {
        type = types.str;
        default = "localhost";
      };

      port = mkOption {
        type = types.port;
        default = config.services.glances.port;
      };
    };

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

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion =
          (filterAttrs (
            _: category: category.layout.style == "row" && category.layout.columns == null
          ) cfg.categories) == { };
        message = "Columns must not be null when using the row layout style";
      }
    ];

    services.homepage-dashboard = {
      enable = true;
      allowedHosts = domain;

      settings = {
        title = "Homepage";
        startUrl = domain;
        theme = "dark";
        language = "de";
        logpath = "/var/log/homepage/homepage.log";
        disableUpdateCheck = true;
        target = "_blank";

        background =
          let
            cfg = config.services.homepage-images;

            subdomain = optionalString cfg.useSubdomain "${cfg.subdomain}.";
            slug = optionalString cfg.useDomainSlug "/${cfg.domainSlug}";

            domain = "http${optionalString config.services.caddy-easify.useHttps "s"}://${subdomain}${baseDomain}${slug}";
          in
          {
            image = "${domain}/active.webp";
            blur = "xs";
            saturate = 50;
            brightness = 50;
            opacity = 50;
          };

        layout = [ { Glances = cfg.glances.layout; } ] ++ (sortCategories cfg.categories);

        headerStyle = "clean";
        statusStyle = "dot";
        hideVersion = "true";
      };

      services =
        [
          (mkIf (cfg.glances.widgets != [ ]) {
            Glances = map (
              widget:
              let
                widgetName = elemAt (attrNames widget) 0;
                widgetCfg = widget.${widgetName};
              in
              {
                ${widgetName}.widget = {
                  inherit (widgetCfg) metric chart;
                  inherit (cfg.glances) version;
                  url = "${cfg.glances.scheme}://${cfg.glances.host}:${toString config.services.glances.port}";
                  type = "glances";
                };
              }
            ) cfg.glances.widgets;
          })
        ]
        ++ (mapAttrsToList (categoryName: category: {
          ${categoryName} = mapAttrsToList (serviceName: service: {
            ${serviceName} = service;
          }) category.services;
        }) cfg.categories);
    };

    services.glances.enable = true;

    services.caddy-easify.reverseProxies.${domain}.port = config.services.homepage-dashboard.listenPort;

    systemd.tmpfiles.settings."10-homepage"."/var/log/homepage".d = {
      user = "root";
      group = "wheel";
      mode = "0755";
    };
  };
}
