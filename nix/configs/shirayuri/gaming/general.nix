{ withSystem, ... }:

{
  flake.nixosModules.shirayuri-gaming =
    { pkgs, ... }:

    {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;

        extraCompatPackages = with pkgs; [
          proton-ge-bin
          dwproton-bin
        ];
      };

      programs.gamemode = {
        enable = true;
        enableRenice = true;

        settings = {
          general.renice = 10;

          cpu.park_cores = true;
          cpu.pin_cores = false;
        };
      };

      specialisation.osu.configuration.self.audio.latency = 32;
    };

  flake.homeModules.hana-gaming =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [
        mangohud
        r2modman
        bs-manager
        lutris
        prismlauncher
        osu-lazer-bin
        dolphin-emu
        melonds
        nwjs-run
      ];
    };

  perSystem =
    { lib, pkgs, ... }:

    {
      packages.prismlauncher = pkgs.symlinkJoin {
        inherit (pkgs.prismlauncher) pname version;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        paths = [
          (pkgs.prismlauncher.override {
            jdks = with pkgs; [
              zulu25
              zulu21
              zulu17
              zulu8
            ];
          })
        ];
        postBuild = with pkgs; ''
          wrapProgram $out/bin/prismlauncher \
            --prefix XDG_DATA_DIRS : "${
              lib.concatStringsSep ":" [
                "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"
                "${gtk3}/share/gsettings-schemas/${gtk3.name}"
              ]
            }"
        '';
      };

      packages.nwjs = pkgs.nwjs.override { alsa-lib = pkgs.alsa-lib-with-plugins; };
      packages.nwjs-run = pkgs.writeShellScriptBin "nwjs-run" ''
        QUERY='def n: if . == "" then "{}" else . end; .name = (.name|n)'

        ${lib.getExe' pkgs.coreutils "cat"} <<< $(${lib.getExe pkgs.jq} "$QUERY" package.json) > package.json
        LD_PRELOAD=${pkgs.nwjs-ffmpeg-prebuilt}/lib/libffmpeg.so ${lib.getExe' pkgs.nwjs "nw"} "$@"
      '';
    };

  flake.overlays.prismlauncher =
    _: prev:

    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }:

      {
        inherit (config.packages) prismlauncher;
      }
    );

  flake.overlays.nwjs =
    _: prev:

    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }:

      {
        inherit (config.packages) nwjs nwjs-run;
      }
    );
}
