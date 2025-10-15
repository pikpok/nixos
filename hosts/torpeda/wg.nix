{
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    netdevs = {
      "50-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          # TODO: move to sops
          PrivateKeyFile = "/wireguard-privkey";
          ListenPort = 51820;
        };
        wireguardPeers = [
          {
            PublicKey = "1P+CYgVuwcRQt9k8Ia/jVZc8f9az3L3QH9+yyZWTFS4=";
            AllowedIPs = ["10.77.0.17" "192.168.100.0/24"];
          }
          # smartphone
          {
            PublicKey = "Tzfxw9VGO8BKXcYyg+rFl/SlUQ51lngIP3J272BxXnw=";
            AllowedIPs = ["10.77.0.10"];
          }
          {
            PublicKey = "J5e2iweoUsEaqblFyjmliXBFJLsmGYwFFyhBtAIPjyc=";
            AllowedIPs = ["10.77.0.8"];
          }
          # laptop
          {
            PublicKey = "6i08L09Wv1aDlByQrIYUix+EcTYtfGeQ0btJ1CR8ZTA=";
            AllowedIPs = ["10.77.0.9"];
          }
        ];
      };
    };
    networks.wg0 = {
      matchConfig.Name = "wg0";
      address = ["10.77.0.1/24"];
      networkConfig = {
        IPMasquerade = "ipv4";
        IPv4Forwarding = true;
      };
      routes = [{Destination = "192.168.100.0/24";}];
    };
  };

  networking.nat.enable = true;

  # firewall rules
  networking.firewall.allowedUDPPorts = [51820];
}
