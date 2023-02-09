{
  sops.secrets."wireguard/key" = {};

  networking.wireguard.interfaces = {
    wg0 = {
      ips = ["10.77.0.11/24"];
      privateKeyFile = "/run/secrets/wireguard/key";
      peers = [
        {
          publicKey = "zJc1neQD2vufvtJPkReaNXlElPQuuBjizW6wwu1pmnA=";
          allowedIPs = ["10.77.0.0/24"];
          endpoint = "47.87.239.24:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
