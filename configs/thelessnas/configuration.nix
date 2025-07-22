{ pkgs, ... }:

{
  sops.secrets.deploymentThelessone.path = "/root/.ssh/deploymentThelessone";

  config'.localization = {
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
}
