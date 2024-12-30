{
  pkgs,
  inputs,
  ...
}:

let
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "pink";
  };
in

{
  imports = [
    inputs.stylix.nixosModules.stylix
    inputs.catppuccin.nixosModules.catppuccin
  ];

  home-manager.sharedModules = [
    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  stylix = {
    enable = true;

    cursor.package = pkgs.rose-pine-cursor;
    cursor.name = "BreezeX-RosePine-Linux";

    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-${catppuccin.flavor}.yaml";
    polarity = "dark";

    image = pkgs.fetchurl {
      url = "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:n3xxlxmlutbyeih4rphvn5o3/bafkreie6qpaxgmgbelgddjezoqknolhqvhtwdpeq4ucfbup35oytb5i3ma@png";
      hash = "sha256-b9z6cs9hkaC1iC4oU5S7iYIYvfroPhepehHf3aLXFoc=";
    };
  };

  hm.catppuccin.gtk.icon = catppuccin;
}
