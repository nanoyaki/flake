{
  perSystem =
    { pkgs, ... }:

    {
      legacyPackages.fetchPixivIllust = pkgs.callPackage (
        {
          stdenvNoCC,
          curl,
          jq,
          cacert,
        }:

        {
          id,
          page ? 0,
          hash ? "",
        }:

        assert builtins.isInt id;
        assert builtins.isInt page;

        stdenvNoCC.mkDerivation {
          name = "illust-${toString id}-page-${toString page}";

          nativeBuildInputs = [
            curl
            jq
          ];

          env = {
            SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
            inherit id page;
          };

          dontUnpack = true;
          dontConfigure = true;
          dontFixup = true;
          doCheck = true;

          checkPhase = ''
            runHook preCheck

            curl --fail -S -v \
              -H "Accept: application/json" \
              -H "Referer: https://www.pixiv.net/artworks/$id" \
              "https://www.pixiv.net/ajax/illust/$id" \
              > metadata.json

            # Verify that page number doesn't exceed page count
            pageCount="$(jq -r '.body.pageCount' metadata.json)"
            if (( $page >= $pageCount )); then
              >&2 echo "Page number $page exceeds the total page count of $pageCount page(s)."
              exit 1
            fi

            runHook postCheck
          '';

          installPhase = ''
            runHook preInstall

            url="$(jq -r '.body.urls.original' metadata.json)"
            url="''${url/_p0/_p$page}"
            curl --fail -S -v \
              -H "Referer: https://www.pixiv.net/" \
              "$url" -O

            cp "$id"* $out

            runHook postInstall
          '';

          outputHashAlgo = "sha256";
          outputHashMode = "recursive";
          outputHash = hash;
        }
      ) { };
    };

  overlays.fetchers = _: _: { config, ... }: {
    inherit (config.legacyPackages) fetchPixivIllust;
  };
}
