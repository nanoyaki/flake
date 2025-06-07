{
  deployment = {
    targetUser = "root";
    targetHost = "192.168.178.91";
    privateKeyName = "deploymentThelessnas";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC6a6yxA1AaSmrf/0Xqvyl6m6QcafD9LU93qEFCmI9Ce";
    extraFlags = [ "--print-build-logs" ];
  };

  services.openssh.knownHosts = {
    # Thelessone
    "192.168.178.84".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkogFEPPOMfkRsBgyuHDQeWQMetWCZbkTpnfajTbu7t";
    # Self
    "192.168.178.91".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPqlQS9C6tms9vFdb0tuaudzCFMH57xcBYnkT3FQVdba";
  };
}
