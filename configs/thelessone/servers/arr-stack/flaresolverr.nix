{ config, ... }:

{
  config'.vopono.allowedTCPPorts = [ config.services.flaresolverr.port ];

  services.flaresolverr = {
    enable = true;
    port = 8191;
  };

  nixpkgs.overlays = [
    (_: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (pyFinal: pyPrev: {
          xvfbwrapper = pyPrev.xvfbwrapper.overridePythonAttrs {
            format = null;
            pyproject = true;

            build-system = [ pyFinal.setuptools ];

            doCheck = true;
          };
        })
      ];
    })
  ];
}
