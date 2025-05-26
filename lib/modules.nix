{
  modules.mkServiceModule =
    {
      name,
      options ? { },
      genericOptions ? { }, # Options to add to any Service module apart from itself
      config ? { },
    }:

    let
      config' = config;
      options' = options;
    in

    {
      lib,
      lib',
      config,
      options,
      ...
    }:

    let
      inherit (lib) mkIf;
      inherit (lib.attrsets) removeAttrs concatMapAttrs isAttrs;
      inherit (lib') mkEnabledOption;

      cfg = config.services'.${name};
    in

    {
      options = {
        services'.${name} =
          {
            enable = mkEnabledOption name;
          }
          // options'
          // (concatMapAttrs (_: opt: opt) (removeAttrs options.generic [ name ]));

        generic.${name} =
          if isAttrs genericOptions then genericOptions else genericOptions { inherit name; };
      };

      config = mkIf cfg.enable (if isAttrs config' then config' else config' { inherit cfg; });
    };
}
