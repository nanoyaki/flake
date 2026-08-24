{
  flake.homeModules.hana-kuroyuri-desktop =
    { pkgs, ... }:

    {
      programs.thunderbird.enable = true;
      programs.thunderbird.profiles.default.isDefault = true;

      home.packages = with pkgs; [
        telegram-desktop
        vesktop
        signal-desktop
        sable-desktop
      ];
    };

  flake.nixosModules.kuroyuri-desktop =
    { pkgs, ... }:

    {
      programs.ausweisapp.enable = true;

      programs.steam.enable = true;
      programs.steam.extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
}
