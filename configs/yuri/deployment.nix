{
  deployment = {
    targetUser = "root";
    targetHost = "events.nanoyaki.space";
    privateKeyName = "deploymentYuri";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIpBykDxGMyZOdW7ECncYK9p6IseXzOnREmb9QCSG9Bn";
    extraFlags = [ "--print-build-logs" ];
  };

  services.openssh.knownHosts."theless.one".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkogFEPPOMfkRsBgyuHDQeWQMetWCZbkTpnfajTbu7t";
}
