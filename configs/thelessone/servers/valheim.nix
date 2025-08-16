{
  inputs,
  pkgs,
  config,
  ...
}:

let
  inherit (inputs) valheim-server;
in

{
  imports = [ valheim-server.nixosModules.default ];

  sops.secrets.valheim-password = { };

  sops.templates."valheim-password.env".file =
    (pkgs.formats.keyValue { }).generate "valheim-password.env.template"
      {
        VH_SERVER_PASSWORD = config.sops.placeholder.valheim-password;
      };

  services.valheim = {
    enable = true;
    openFirewall = true;
    passwordEnvFile = config.sops.templates."valheim-password.env".path;

    noGraphics = true;
    public = true;
    serverName = "Cozy server x3";
    worldName = "Test12";
  };
}
