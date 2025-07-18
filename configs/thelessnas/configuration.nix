{ pkgs, ... }:

{
  sec."deploymentThelessone/private".path = "/root/.ssh/deploymentThelessone";

  nanoflake.localization = {
    timezone = "Europe/Vienna";
    language = [
      "de_AT"
      "en"
    ];
    locale = "de_AT.UTF-8";
    extraLocales = [
      "de_DE.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
    ];
  };

  # for remote switching
  environment.systemPackages = [ pkgs.tmux ];

  services.iperf3 = {
    enable = true;
    openFirewall = true;
  };

  hm.home.stateVersion = "25.11";
  system.stateVersion = "25.11";
}
