{
  deployment = {
    targetUser = "root";
    targetHost = "100.86.224.101";
    privateKeyName = "deploymentThelessone";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMc3xjLJxASdTuLIrsvok5Wpm5N8TO1CI9vHt2z3oPPC";
    extraFlags = [ "--print-build-logs" ];
  };

  services.openssh.knownHosts = {
    "100.86.224.101".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkogFEPPOMfkRsBgyuHDQeWQMetWCZbkTpnfajTbu7t";
    "theless.one".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkogFEPPOMfkRsBgyuHDQeWQMetWCZbkTpnfajTbu7t";

    "100.114.189.127".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILp5Szm657DfoXyTuO0h25RQpPxqtYicFpboLpcL5RMb";
    "events.nanoyaki.space".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILp5Szm657DfoXyTuO0h25RQpPxqtYicFpboLpcL5RMb";
  };
}
