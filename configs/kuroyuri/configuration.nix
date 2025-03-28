{ pkgs, ... }:

{
  system.stateVersion = "24.05";
  hm.home.stateVersion = "24.11";

  nanoflake = {
    localization = {
      language = [
        "en_GB"
        "de_DE"
        "ja_JP"
      ];
      extraLocales = [ "ja_JP.UTF-8/UTF-8" ];
    };

    firefox.enablePolicies = true;
  };

  hm.home.file.".face.icon".source = pkgs.fetchurl {
    url = "https://cdn.bsky.app/img/avatar/plain/did:plc:majihettvb7ieflgmkvujecu/bafkreib6be5oip6rht4vqnmldx5hzulr6irh55yarwbmxt2us2imfoiyd4@png";
    hash = "sha256-mQ8il+zU30EAxFAulUFkkXvYs9gubKCeQtaYRyJNXJ8=";
  };
}
