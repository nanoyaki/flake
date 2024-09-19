{
  lib,
  config,
  username,
  ...
}:
with lib; let
  cfg = config.modules.virtualisation;
in {
  options.modules.virtualisation = {
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
