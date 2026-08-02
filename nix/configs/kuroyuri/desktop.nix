{
  flake.homeModules.hana-kuroyuri-desktop =
    { pkgs, ... }:

    {
      programs.thunderbird.enable = true;
      programs.thunderbird.profiles.default.isDefault = true;

      home.packages = with pkgs; [
        element-desktop
        telegram-desktop
        vesktop
        signal-desktop
      ];
    };

  flake.nixosModules.kuroyuri-desktop.programs.ausweisapp.enable = true;
}
