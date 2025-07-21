{
  deployment = {
    targetUser = "root";
    targetHost = "100.64.64.1";
    privateKeyName = "deploymentThelessone";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMc3xjLJxASdTuLIrsvok5Wpm5N8TO1CI9vHt2z3oPPC";
    extraFlags = [ "--print-build-logs" ];
  };

  services.openssh.knownHosts = {
    "100.64.64.1".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkogFEPPOMfkRsBgyuHDQeWQMetWCZbkTpnfajTbu7t";
    "theless.one".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkogFEPPOMfkRsBgyuHDQeWQMetWCZbkTpnfajTbu7t";

    "100.64.64.3".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILp5Szm657DfoXyTuO0h25RQpPxqtYicFpboLpcL5RMb";
    "events.nanoyaki.space".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILp5Szm657DfoXyTuO0h25RQpPxqtYicFpboLpcL5RMb";

    # Thelessnas
    "10.0.0.6".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPqlQS9C6tms9vFdb0tuaudzCFMH57xcBYnkT3FQVdba";
  };
}
