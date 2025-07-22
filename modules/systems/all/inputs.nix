{
  lib',
  config,
  ...
}:

let
  inherit (lib'.options) mkDefault mkStrOption;
  cfg = config.config'.keyboard;
in

{
  options.config'.keyboard = {
    layout = mkDefault "de" mkStrOption;
    variant = mkStrOption;
  };

  config.console.keyMap = cfg.layout;
}
