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

      entryPoints.websecure.address = ":443";

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
          pihole = {
            rule = "Host(`pihole.pikpok.xyz`)";
            tls.certResolver = "cloudflare";
            service = "pihole";
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
          uptime-kuma = {
            rule = "Host(`uptime.pikpok.xyz`)";
            tls.certResolver = "cloudflare";
            service = "uptime-kuma";
          };
          actual = {
            rule = "Host(`actual.pikpok.xyz`)";
            tls.certResolver = "cloudflare";
            service = "actual";
          };
          n8n = {
            rule = "Host(`n8n.pikpok.xyz`)";
            tls.certResolver = "cloudflare";
            service = "n8n";
          };
          immich = {
            rule = "Host(`immich.pikpok.xyz`)";
            tls.certResolver = "cloudflare";
            service = "immich";
          };
        };
        services = {
          teslamate = {loadBalancer = {servers = [{url = "http://127.0.0.1:4000";}];};};
          photoprism = {loadBalancer = {servers = [{url = "http://127.0.0.1:2342";}];};};
          pihole = {loadBalancer = {servers = [{url = "http://127.0.0.1:81";}];};};
          home-assistant = {loadBalancer = {servers = [{url = "http://127.0.0.1:8123";}];};};
          grafana = {loadBalancer = {servers = [{url = "http://127.0.0.1:3000";}];};};
          actual = {loadBalancer = {servers = [{url = "http://127.0.0.1:5006";}];};};
          n8n = {loadBalancer = {servers = [{url = "http://127.0.0.1:5678";}];};};
          immich = {loadBalancer = {servers = [{url = "http://127.0.0.1:2283";}];};};
          uptime-kuma = {loadBalancer = {servers = [{url = "http://${config.services.uptime-kuma.settings.HOST}:${config.services.uptime-kuma.settings.PORT}";}];};};
        };
      };
    };
  };
}
