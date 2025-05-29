{
  lib,
  lib',
  ...
}:

let
  inherit (lib'.options)
    mkDefault
    mkListOf
    mkSingleAttrOf
    mkAttrsOf
    mkNullOr
    mkSubmoduleOption
    mkStrOption
    mkFalseOption
    mkEnumOption
    mkIntOption
    mkPortOption
    mkTrueOption
    ;

  inherit (lib) mkIf;
  inherit (lib.attrsets) attrNames filterAttrs mapAttrsToList;
  inherit (lib.lists) toposort elemAt;
  inherit (lib.strings) toInt optionalString;
  inherit (lib.versions) major;

  sortCategories =
    categories:
    let
      sortedNames = toposort (a: b: categories.${a}.before == b) (attrNames categories);
      categoryNames = sortedNames.result or (attrNames categories);
    in
    map (name: { ${name} = categories.${name}.layout; }) categoryNames;
in

lib'.modules.mkModule {
  name = "homepage";

  options =
    { config, ... }:

    {
      glances = {
        widgets =
          mkDefault
            [
              { Info.metric = "info"; }
              { "Cpu usage".metric = "cpu"; }
              { "Disk usage".metric = "fs:/"; }
              { "Memory usage".metric = "memory"; }
            ]
            (
              mkListOf (
                mkSingleAttrOf (mkSubmoduleOption {
                  metric = mkStrOption;
                  chart = mkFalseOption;
                })
              )
            );

        layout = {
          header = mkFalseOption;

          style = mkEnumOption [
            "row"
            "column"
          ];

          columns = mkDefault 4 mkIntOption;
        };

        version = mkDefault (toInt (major config.services.glances.package.version)) mkIntOption;

        scheme = mkEnumOption [
          "http"
          "https"
        ];

        host = mkDefault "localhost" mkStrOption;

        port = mkDefault config.services.glances.port mkPortOption;
      };

      categories = mkAttrsOf (mkSubmoduleOption {
        layout = {
          header = mkTrueOption;

          style = mkEnumOption [
            "column"
            "row"
          ];

          columns = mkNullOr mkIntOption;
        };

        services = mkAttrsOf (mkSubmoduleOption {
          description = mkStrOption;
          href = mkStrOption;
          siteMonitor = mkStrOption;
          icon = mkStrOption;
        });

        before = mkNullOr mkStrOption;
      });
    };

  config =
    {
      cfg,
      cfg',
      config,
      helpers',
      ...
    }:

    let
      domain = helpers'.caddy.domain cfg;
    in

    {
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
        allowedHosts = "${optionalString cfg.useSubdomain "${cfg.subdomain}."}${cfg'.caddy.baseDomain}";

        settings = {
          title = "Homepage";
          startUrl = domain;
          theme = "dark";
          language = "de";
          logpath = "/var/log/homepage/homepage.log";
          disableUpdateCheck = true;
          target = "_blank";

          background = {
            image = "${helpers'.caddy.domain cfg'.homepage-images}/active.webp";
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

      services'.caddy.reverseProxies.${domain}.port = config.services.homepage-dashboard.listenPort;

      systemd.tmpfiles.settings."10-homepage"."/var/log/homepage".d = {
        user = "root";
        group = "wheel";
        mode = "0755";
      };
    };

  sharedOptions.homepage = {
    category = mkStrOption;
    description = mkStrOption;
  };

  dependencies = [
    "homepage-images"
    "caddy"
  ];
}
