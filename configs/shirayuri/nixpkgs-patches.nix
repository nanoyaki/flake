_:

{
  nixpkgs.overlays = [
    (final: prev: {
      prismlauncher = final.symlinkJoin {
        inherit (prev.prismlauncher) pname version;
        nativeBuildInputs = [ final.makeWrapper ];
        paths = [
          (prev.prismlauncher.override {
            jdks = with final; [
              zulu25
              zulu21
              zulu17
              zulu8
            ];
          })
        ];
        postBuild = with final; ''
          wrapProgram $out/bin/prismlauncher \
            --prefix XDG_DATA_DIRS : "${
              lib.concatStringsSep ":" [
                "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"
                "${gtk3}/share/gsettings-schemas/${gtk3.name}"
              ]
            }"
        '';
      };
    })
  ];
}
