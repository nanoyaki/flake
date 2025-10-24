{
  config,
  ...
}:

{
  sops.secrets.wg0 = { };

  networking.wg-quick.interfaces.wg0 = {
    address = [
      "10.101.0.2/32"
      "fd10::2/128"
    ];
    privateKeyFile = config.sops.secrets.wg0.path;

    peers = [
      {
        publicKey = "kdBOsYomUk9YEFs+qSsKHnbaMAL6r57IlkJoNweRKj8=";
        endpoint = "nanoyaki.space:51820";
        allowedIPs = [
          "10.101.0.1/32"
          "fd10::1/128"
        ];
        persistentKeepalive = 25;
      }
    ];
  };
}
