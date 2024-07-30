{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.services.nano.virtualisation;
in {
  options.services.nano.virtualisation = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable custom virtualisation options.";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.virtualbox.host.enable = true;
    users.users.${username}.extraGroups = ["vboxusers"];
  };
}
