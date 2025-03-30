{
  deployment = {
    targetUser = "root";
    targetHost = "100.114.189.127";
    privateKeyName = "deploymentYuri";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIpBykDxGMyZOdW7ECncYK9p6IseXzOnREmb9QCSG9Bn";
    extraFlags = [ "--print-build-logs" ];
  };

  services.openssh.knownHosts = {
    "100.86.224.101".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkogFEPPOMfkRsBgyuHDQeWQMetWCZbkTpnfajTbu7t";
    "theless.one".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkogFEPPOMfkRsBgyuHDQeWQMetWCZbkTpnfajTbu7t";
  };
}
