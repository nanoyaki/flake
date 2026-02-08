{
  flake.nixosModules.wayland =
    { config, ... }:

    {
      nixpkgs.overlays = [
        (_: prev: {
          weston = prev.weston.overrideAttrs (prevAttrs: {
            mesonFlags = prevAttrs.mesonFlags or [ ] ++ [ (prev.lib.mesonBool "backend-vnc" false) ];
          });
        })
      ];

      services.displayManager.autoLogin = {
        enable = true;
        user = config.self.mainUser;
      };

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        GDK_BACKEND = "wayland";
      };

      services.libinput.mouse.accelProfile = "flat";
      services.xserver.xkb.layout = "de";
    };
}
