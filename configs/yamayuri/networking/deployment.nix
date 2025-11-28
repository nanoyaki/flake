{
  sops.secrets.id_yamayuri_deployment.path = "/etc/ssh/id_yamayuri_deployment";

  nanoSystem.deployment.addresses."10.0.0.3" = {
    targetUser = "root";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILvOO+/5u4E59HzabEuLglMHPBF7hVfXfIddiyL+ubd/";
  };

  services.openssh.knownHosts."theless.one".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkogFEPPOMfkRsBgyuHDQeWQMetWCZbkTpnfajTbu7t";
}
