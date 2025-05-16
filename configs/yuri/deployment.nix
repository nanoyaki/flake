{
  deployment = {
    targetUser = "root";
    targetHost = "100.64.64.3";
    privateKeyName = "deploymentYuri";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIpBykDxGMyZOdW7ECncYK9p6IseXzOnREmb9QCSG9Bn";
    extraFlags = [ "--print-build-logs" ];
  };

  services.openssh.knownHosts = {
    "100.64.64.1".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkogFEPPOMfkRsBgyuHDQeWQMetWCZbkTpnfajTbu7t";
    "theless.one".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkogFEPPOMfkRsBgyuHDQeWQMetWCZbkTpnfajTbu7t";
  };
}
