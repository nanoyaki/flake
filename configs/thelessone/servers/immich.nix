{
  lib,
  pkgs,
  config,
  ...
}:

{
  config'.immich.enable = true;

  services.immich.package = pkgs.immich.overrideAttrs (
    oldAttrs:
    lib.optionalAttrs (lib.versionOlder oldAttrs.version "1.142.1") rec {
      version = "1.142.1";
      src = pkgs.fetchFromGitHub {
        owner = "immich-app";
        repo = "immich";
        tag = "v${version}";
        hash = "sha256-u538GWupnkH2K81Uk9yEuHc3pAeVexnJOnhWo7gElL0=";
      };

      pnpmDeps = pkgs.pnpm_10.fetchDeps {
        pname = "immich";
        inherit version src;
        fetcherVersion = 2;
        hash = "sha256-aYG5SpFZxhbz32YAdP39RYwn2GV+mFWhddd4IFuPuz8=";
      };
    }
  );

  services.immich-public-proxy = {
    enable = true;
    immichUrl = "http://localhost:2283";
    port = 19220;
    settings.allowDownloadAll = 1;
  };

  config'.caddy.vHost."images.theless.one".proxy = {
    inherit (config.services.immich-public-proxy) port;
  };
}
