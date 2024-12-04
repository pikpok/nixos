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
        };
        services = {
          teslamate.loadBalancer.servers = [{url = "http://127.0.0.1:4000";}];
          photoprism.loadBalancer.servers = [{url = "http://127.0.0.1:2342";}];
          pihole.loadBalancer.servers = [{url = "http://127.0.0.1:81";}];
          home-assistant.loadBalancer.servers = [{url = "http://127.0.0.1:8123";}];
          grafana.loadBalancer.servers = [{url = "http://127.0.0.1:3000";}];
          actual.loadBalancer.servers = [{url = "http://127.0.0.1:5006";}];
          immich.loadBalancer.servers = [{url = "http://127.0.0.1:2283";}];
          matrix.loadBalancer.servers = [{url = "http://127.0.0.1:6167";}];
          ntfy.loadBalancer.servers = [{url = "http://127.0.0.1:2586";}];
          windmill.loadBalancer.servers = [{url = "http://127.0.0.1:${toString config.services.windmill.serverPort}";}];
          uptime-kuma.loadBalancer.servers = [{url = "http://${config.services.uptime-kuma.settings.HOST}:${config.services.uptime-kuma.settings.PORT}";}];
        };
      };
    };
  };
}
