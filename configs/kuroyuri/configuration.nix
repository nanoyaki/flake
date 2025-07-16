{ pkgs, username, ... }:

{
  sec = {
    githubToken = {
      owner = username;
      path = "/home/${username}/secrets/githubToken";
    };
    "keys.toml".owner = username;
  };

  system.stateVersion = "24.05";
  hm.home.stateVersion = "24.11";

  networking.networkmanager.enable = true;

  nanoflake = {
    localization.language = [
      "en_GB"
      "de_DE"
      "ja_JP"
    ];

    firefox.enablePolicies = true;
  };

  environment.systemPackages = with pkgs; [
    jq
    meow
    pyon
    nvtopPackages.amd
    wl-clipboard
    gimp3-with-plugins
    feishin
    grayjay
  ];

  hm.home.file.".face.icon".source = pkgs.fetchurl {
    url = "https://cdn.bsky.app/img/avatar/plain/did:plc:majihettvb7ieflgmkvujecu/bafkreib6be5oip6rht4vqnmldx5hzulr6irh55yarwbmxt2us2imfoiyd4@png";
    hash = "sha256-mQ8il+zU30EAxFAulUFkkXvYs9gubKCeQtaYRyJNXJ8=";
  };
}
