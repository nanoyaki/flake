{
  deployment = {
    targetUser = "root";
    targetHost = "192.168.178.91";
    privateKeyName = "deploymentThelessnas";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC6a6yxA1AaSmrf/0Xqvyl6m6QcafD9LU93qEFCmI9Ce";
    extraFlags = [ "--print-build-logs" ];
  };

  services.openssh.knownHosts."192.168.178.84".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkogFEPPOMfkRsBgyuHDQeWQMetWCZbkTpnfajTbu7t";
}
