{
  lib,
  pkgs,
  ...
}:

{
  stylix = {
    base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/da-one-sea.yaml";
    image = lib.mkForce (
      pkgs.fetchurl {
        url = "https://na55l3zepb4kcg0zryqbdnay.theless.one/nix.png";
        hash = "sha256-G2a9UxqPXQNj+sLxDKwkT5D8/6W6rWWoQFL23jXxsrU=";
      }
    );
  };
}
