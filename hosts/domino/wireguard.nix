{pkgs, ...}: {
  sops.secrets."wireguard" = {
    sopsFile = ../../secrets/domino/wireguard.yaml;
  };

  networking.wireguard.interfaces.wg0 = {
    ips = ["10.77.0.17/24"];
    privateKeyFile = "/run/secrets/wireguard";
    preSetup = "${pkgs.procps}/bin/sysctl -w net.ipv4.ip_forward=1; ${pkgs.nftables}/bin/nft add rule nat POSTROUTING oifname enp1s0 masquerade";
    peers = [
      {
        publicKey = "zJc1neQD2vufvtJPkReaNXlElPQuuBjizW6wwu1pmnA=";
        allowedIPs = ["10.77.0.0/24"];
        endpoint = "c.pikpok.xyz:51820";
        persistentKeepalive = 25;
      }
    ];
  };
}
