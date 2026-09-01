{
  sops.secrets."wireguard/key" = {};

  networking.wireguard.interfaces = {
    wg0 = {
      ips = ["10.77.0.11/24"];
      privateKeyFile = "/run/secrets/wireguard/key";
      peers = [
      {
          publicKey = "W9iVN2ibCg3oXUVzLYgViL3pmAa2f2DGwWoX2yKyIhA=";
          allowedIPs = ["10.77.0.0/24"];
          endpoint = "wg.pikpok.xyz:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
