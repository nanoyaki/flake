let
  cfg = {
    targetUser = "root";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIpBykDxGMyZOdW7ECncYK9p6IseXzOnREmb9QCSG9Bn";
  };
in

{
  nanoSystem.deployment.addresses = {
    "100.64.64.3" = cfg;
    "10.0.0.3" = cfg;
  };

  services.openssh.knownHosts = {
    "100.64.64.1".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkogFEPPOMfkRsBgyuHDQeWQMetWCZbkTpnfajTbu7t";
    "theless.one".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkogFEPPOMfkRsBgyuHDQeWQMetWCZbkTpnfajTbu7t";
  };
}
