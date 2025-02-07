{ lib, pkgs, ... }:

{
  system.stateVersion = "24.05";
  hm.home.stateVersion = "24.11";

  nanoflake.theme.enableAutoStylix = true;

  stylix.image = lib.mkForce (
    pkgs.fetchurl {
      url = "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:n3xxlxmlutbyeih4rphvn5o3/bafkreie6qpaxgmgbelgddjezoqknolhqvhtwdpeq4ucfbup35oytb5i3ma@png";
      hash = "sha256-b9z6cs9hkaC1iC4oU5S7iYIYvfroPhepehHf3aLXFoc=";
    }
  );
}
