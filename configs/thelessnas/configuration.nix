{ pkgs, ... }:

{
  sops.secrets.deploymentThelessone.path = "/root/.ssh/deploymentThelessone";

  # for remote switching
  environment.systemPackages = [ pkgs.tmux ];

  services.iperf3 = {
    enable = true;
    openFirewall = true;
  };
}
