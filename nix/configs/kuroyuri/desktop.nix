{
  flake.homeModules.hana-kuroyuri-desktop =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [ vesktop ];

      programs.thunderbird.enable = true;
      programs.thunderbird.profiles.default.isDefault = true;
    };
}
