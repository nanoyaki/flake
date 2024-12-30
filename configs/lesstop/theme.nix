{
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.stylix.nixosModules.stylix ];

  stylix = {
    cursor.package = pkgs.rose-pine-cursor;
    cursor.name = "BreezeX-RosePine-Linux";

    base16Scheme = "${pkgs.base16-schemes}/share/themes/pasque.yaml";
    polarity = "dark";

    image = pkgs.fetchurl {
      url = "https://na55l3zepb4kcg0zryqbdnay.theless.one/nix.png";
      hash = lib.fakeHash;
    };
  };
}
