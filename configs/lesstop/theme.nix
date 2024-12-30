{
  lib,
  pkgs,
  ...
}:

{
  imports = [ ../common/theme.nix ];

  stylix = lib.mkForce {
    enable = true;

    cursor.package = pkgs.rose-pine-cursor;
    cursor.name = "BreezeX-RosePine-Linux";

    base16Scheme = "${pkgs.base16-schemes}/share/themes/pasque.yaml";
    polarity = "dark";

    image = pkgs.fetchurl {
      url = "https://na55l3zepb4kcg0zryqbdnay.theless.one/nix.png";
      hash = "sha256-G2a9UxqPXQNj+sLxDKwkT5D8/6W6rWWoQFL23jXxsrU=";
    };
  };
}
