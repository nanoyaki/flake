{
  deployment = {
    targetUser = "root";
    targetHost = "theless.one";
    privateKeyName = "deploymentThelessone";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMc3xjLJxASdTuLIrsvok5Wpm5N8TO1CI9vHt2z3oPPC";
    extraFlags = [ "--print-build-logs" ];
  };

  services.openssh.knownHosts = {
    "theless.one".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkogFEPPOMfkRsBgyuHDQeWQMetWCZbkTpnfajTbu7t";
    "events.nanoyaki.space".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILp5Szm657DfoXyTuO0h25RQpPxqtYicFpboLpcL5RMb";
  };
}
