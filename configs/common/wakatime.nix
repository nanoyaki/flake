{
  lib,
  pkgs,
  config,
  username,
  ...
}:

let
  cfg = config.services.wakapi;
in

{
  sec."wakatime/apiKey".owner = username;
  sec."wakapi/salt".owner = "wakapi";

  home-manager.sharedModules = [
    ./home/wakatime.nix
  ];

  hm.programs.wakatime = {
    enable = true;

    settings.settings = {
      api_url = "http://localhost:${toString cfg.settings.server.port}/api";
      api_key_vault_cmd = "${lib.getExe' pkgs.coreutils "cat"} ${config.sec."wakatime/apiKey".path}";
    };
  };

  services.wakapi = {
    enable = true;

    database.createLocally = true;

    passwordSaltFile = config.sec."wakapi/salt".path;
    settings = {
      db = {
        dialect = "postgres";
        name = "wakapi";
        user = "wakapi";
      };
      server.port = 8437;
    };
  };
}
