{
  inputs,
  inputs',
  ...
}:

let
  inherit (inputs) nixpkgs-wayland;
  inherit (inputs') wkeys;
in

{
  nix.settings = {
    trusted-substituters = [
      "https://nixpkgs-wayland.cachix.org"
    ];
    trusted-public-keys = [
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };

  nixpkgs.overlays = [
    nixpkgs-wayland.overlay
    (final: _: {
      wkeys = wkeys.packages.default.overrideAttrs (prevAttrs: {
        nativeBuildInputs = prevAttrs.nativeBuildInputs or [ ] ++ [ final.copyDesktopItems ];

        desktopItems = [
          (final.makeDesktopItem {
            name = prevAttrs.pname;
            desktopName = "Wkeys";
            genericName = "Input Method";
            comment = "Start Input Method";
            exec = "wkeys";
            terminal = false;
            categories = [
              "System"
              "Utility"
            ];
            startupNotify = false;
            onlyShowIn = [ "KDE" ];
            extraConfig = {
              X-KDE-StartupNotify = "false";
              X-KDE-Wayland-VirtualKeyboard = "true";
              X-KDE-Wayland-Interfaces = "org_kde_plasma_window_management";
            };
          })
        ];
      });
    })
  ];
}
