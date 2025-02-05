{config, ...}: {
  sops.secrets."traefik-cloudflare" = {
    sopsFile = ../../secrets/domino/traefik-cloudflare.env;
    format = "dotenv";
    owner = "traefik";
    group = "traefik";
  };

  services.traefik = {
    enable = true;
    environmentFiles = ["/run/secrets/traefik-cloudflare"];
    staticConfigOptions = {
      global = {
        checkNewVersion = false;
        sendAnonymousUsage = false;
      };

      entryPoints.web = {
        address = ":80";
        http = {
          redirections = {
            entryPoint = {
              to = "websecure";
              scheme = "https";
              permanent = true;
            };
          };
        };
      };

      entryPoints.websecure = {
        address = ":443";
        forwardedHeaders = {
          trustedIPs = ["127.0.0.1/32" "::1/128" "192.168.100.0/24"];
        };
      };

      certificatesResolvers.cloudflare.acme = {
        email = "krzysztof@bezrak.pl";
        storage = "${config.services.traefik.dataDir}/acme.json";
        dnsChallenge = {
          provider = "cloudflare";
          resolvers = ["1.1.1.1:53"];
        };
      };
    };
    dynamicConfigOptions = {
      http = {
        routers = {
          teslamate = {
            rule = "Host(`teslamate.pikpok.xyz`)";
            tls.certResolver = "cloudflare";
            service = "teslamate";
          };
          photoprism = {
            rule = "Host(`photoprism.pikpok.xyz`)";
            tls.certResolver = "cloudflare";
            service = "photoprism";
          };
          home-assistant = {
            rule = "Host(`ha.pikpok.xyz`)";
            tls.certResolver = "cloudflare";
            service = "home-assistant";
          };
          grafana = {
            rule = "Host(`grafana.pikpok.xyz`)";
            tls.certResolver = "cloudflare";
            service = "grafana";
          };
          actual = {
            rule = "Host(`actual.pikpok.xyz`)";
            tls.certResolver = "cloudflare";
            service = "actual";
          };
          immich = {
            rule = "Host(`immich.pikpok.xyz`)";
            tls.certResolver = "cloudflare";
            service = "immich";
          };
          matrix = {
            rule = "Host(`matrix.pikpok.xyz`)";
            tls.certResolver = "cloudflare";
            service = "matrix";
          };
          ntfy = {
            rule = "Host(`ntfy.pikpok.xyz`)";
            tls.certResolver = "cloudflare";
            service = "ntfy";
          };
          windmill = {
            rule = "Host(`windmill.pikpok.xyz`)";
            tls.certResolver = "cloudflare";
            service = "windmill";
          };
          nextcloud = {
            rule = "Host(`c.pikpok.xyz`)";
            tls.certResolver = "cloudflare";
            service = "nextcloud";
          };
          prometheus = {
            rule = "Host(`prometheus.pikpok.xyz`)";
            tls.certResolver = "cloudflare";
            service = "prometheus";
          };
          alertmanager = {
            rule = "Host(`alertmanager.pikpok.xyz`)";
            tls.certResolver = "cloudflare";
            service = "alertmanager";
          };
        };
        services = {
          teslamate.loadBalancer.servers = [{url = "http://127.0.0.1:${toString config.services.teslamate.port}";}];
          photoprism.loadBalancer.servers = [{url = "http://127.0.0.1:2342";}];
          home-assistant.loadBalancer.servers = [{url = "http://127.0.0.1:8123";}];
          grafana.loadBalancer.servers = [{url = "http://127.0.0.1:3000";}];
          actual.loadBalancer.servers = [{url = "http://127.0.0.1:5006";}];
          immich.loadBalancer.servers = [{url = "http://127.0.0.1:2283";}];
          matrix.loadBalancer.servers = [{url = "http://127.0.0.1:6167";}];
          ntfy.loadBalancer.servers = [{url = "http://127.0.0.1:2586";}];
          windmill.loadBalancer.servers = [{url = "http://127.0.0.1:8000";}];
          nextcloud.loadBalancer.servers = [{url = "http://127.0.0.1:8081";}];
          prometheus.loadBalancer.servers = [{url = "http://127.0.0.1:${toString config.services.prometheus.port}";}];
          alertmanager.loadBalancer.servers = [{url = "http://[::1]:${toString config.services.prometheus.alertmanager.port}";}];
        };
      };
    };
  };
}
