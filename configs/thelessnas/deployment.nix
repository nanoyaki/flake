{
  nanoSystem.deployment.addresses."10.0.0.6" = {
    targetUser = "root";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC6a6yxA1AaSmrf/0Xqvyl6m6QcafD9LU93qEFCmI9Ce";
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
