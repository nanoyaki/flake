{
  deployment = {
    targetUser = "root";
    targetHost = "10.0.0.6";
    privateKeyName = "deploymentThelessnas";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC6a6yxA1AaSmrf/0Xqvyl6m6QcafD9LU93qEFCmI9Ce";
    extraFlags = [ "--print-build-logs" ];
  };

  services.openssh.knownHosts = {
    # Thelessone
    "10.0.0.5".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkogFEPPOMfkRsBgyuHDQeWQMetWCZbkTpnfajTbu7t";
    # Self
    "10.0.0.6".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPqlQS9C6tms9vFdb0tuaudzCFMH57xcBYnkT3FQVdba";
  };
}
