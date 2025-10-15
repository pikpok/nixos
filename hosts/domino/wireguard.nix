{pkgs, ...}: {
  sops.secrets."wireguard" = {
    sopsFile = ../../secrets/domino/wireguard.yaml;
  };

  networking.wireguard.interfaces.wg0 = {
    ips = ["10.77.0.17/24"];
    privateKeyFile = "/run/secrets/wireguard";
    preSetup = "${pkgs.procps}/bin/sysctl -w net.ipv4.ip_forward=1";
    peers = [
      {
        publicKey = "3SprJn+Un1DnP9bZkT8z8xdBzX0LUBkIaNAt3ner8XU=";
        allowedIPs = ["10.77.0.0/24"];
        endpoint = "wg.pikpok.xyz:51820";
        persistentKeepalive = 25;
      }
    ];
  };
}
