{
  sops.secrets.id_yamayuri_deployment.path = "/etc/ssh/id_yamayuri_deployment";

  config'.deployment."10.0.0.101" = {
    targetUser = "root";
    privateKeyName = "id_yamayuri_deployment";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILvOO+/5u4E59HzabEuLglMHPBF7hVfXfIddiyL+ubd/";
  };

  services.openssh.knownHosts."theless.one".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkogFEPPOMfkRsBgyuHDQeWQMetWCZbkTpnfajTbu7t";
}
