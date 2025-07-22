{
  config,
  pkgs,
  lib,
  ...
}: let
  blackboxConfig = {
    modules = {
      http_2xx = {
        prober = "http";
        timeout = "5s";
        http = {
          method = "GET";
          valid_status_codes = [200 403];
          follow_redirects = true;
        };
      };
    };
  };

  # Extract all services from Traefik configuration
  traefikServices = with lib; let
    routers = config.services.traefik.dynamicConfigOptions.http.routers;
    # Convert the router attrset to a list of services with their domains
    servicesList =
      mapAttrsToList (name: value: {
        name = name;
        domain = head (splitString " " (removePrefix "Host(`" (removeSuffix "`)" value.rule)));
      })
      routers;
  in
    servicesList;

  # Generate scrape configs for all services
  servicesScrapeConfigs =
    map (service: {
      job_name = "${service.name}-uptime";
      metrics_path = "/probe";
      params = {
        module = ["http_2xx"];
        target = ["https://${service.domain}"];
      };
      static_configs = [
        {
          targets = ["127.0.0.1:${toString config.services.prometheus.exporters.blackbox.port}"];
          labels = {
            service_name = service.name;
          };
        }
      ];
      relabel_configs = [
        {
          source_labels = ["__param_target"];
          target_label = "instance";
        }
        {
          source_labels = ["service_name"];
          target_label = "service";
        }
      ];
    })
    traefikServices;

  alertRules = builtins.toJSON {
    groups = [
      {
        name = "node";
        rules = [
          {
            alert = "HighCpuLoad";
            expr = "100 - (avg by (instance) (rate(node_cpu_seconds_total{mode='idle'}[5m])) * 100) > 80";
            for = "5m";
            labels = {
              severity = "warning";
            };
            annotations = {
              summary = "CPU load is over 80%";
              description = "CPU load on {{ $labels.instance }} has been above 80% for the last 5 minutes.";
            };
          }
          {
            alert = "DiskSpaceLow";
            expr = "100 - ((node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes) > 80";
            for = "5m";
            labels = {
              severity = "warning";
            };
            annotations = {
              summary = "Disk space usage is over 80%";
              description = "Disk space usage on {{ $labels.instance }} (mount: {{ $labels.mountpoint }}) has been above 80% for the last 5 minutes.";
            };
          }
          {
            alert = "MemoryUsageHigh";
            expr = "100 - ((node_memory_MemAvailable_bytes * 100) / node_memory_MemTotal_bytes) > 80";
            for = "5m";
            labels = {
              severity = "warning";
            };
            annotations = {
              summary = "Memory usage is over 80%";
              description = "Memory usage on {{ $labels.instance }} has been above 80% for the last 5 minutes.";
            };
          }
          {
            alert = "NasMountUnavailable";
            expr = "node_filesystem_avail_bytes{mountpoint='/mnt/nas'} == 0";
            for = "5m";
            labels = {
              severity = "critical";
            };
            annotations = {
              summary = "NAS mount is unavailable";
              description = "The NAS mount at /mnt/nas is not accessible.";
            };
          }
        ];
      }
      {
        name = "services";
        rules = [
          {
            alert = "ServiceDown";
            expr = "probe_success == 0";
            for = "5m";
            labels = {
              severity = "critical";
            };
            annotations = {
              summary = "Service {{ $labels.service }} is down";
              description = "Service {{ $labels.service }} ({{ $labels.instance }}) has been down for more than 5 minutes.";
            };
          }
        ];
      }
      {
        name = "database";
        rules = [
          {
            alert = "PostgresqlDown";
            expr = "node_systemd_unit_state{name='postgresql.service',state='active'} != 1";
            for = "5m";
            labels = {
              severity = "critical";
            };
            annotations = {
              summary = "PostgreSQL is down";
              description = "PostgreSQL service has been down for more than 5 minutes.";
            };
          }
        ];
      }
      {
        name = "mqtt";
        rules = [
          {
            alert = "MosquittoDown";
            expr = "node_systemd_unit_state{name='mosquitto.service',state='active'} != 1";
            for = "5m";
            labels = {
              severity = "critical";
            };
            annotations = {
              summary = "Mosquitto MQTT broker is down";
              description = "The Mosquitto MQTT broker service has been down for more than 5 minutes.";
            };
          }
        ];
      }
    ];
  };
in {
  services.prometheus = {
    enable = true;
    port = 9090;

    exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd" "diskstats" "filesystem"];
        port = 9100;
      };
      blackbox = {
        enable = true;
        configFile = pkgs.writeText "blackbox.json" (builtins.toJSON blackboxConfig);
      };
    };

    scrapeConfigs =
      [
        {
          job_name = "node";
          static_configs = [{targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];}];
        }
      ]
      ++ servicesScrapeConfigs;

    rules = [alertRules];

    alertmanagers = [
      {
        scheme = "http";
        static_configs = [{targets = ["[::1]:${toString config.services.prometheus.alertmanager.port}"];}];
      }
    ];
  };

  services.prometheus.alertmanager = {
    enable = true;
    listenAddress = "[::1]";
    port = 9093;
    configuration = {
      global.resolve_timeout = "5m";
      route = {
        group_by = ["alertname"];
        group_wait = "30s";
        group_interval = "5m";
        repeat_interval = "12h";
        receiver = "ntfy";
      };
      receivers = [
        {
          name = "ntfy";
          webhook_configs = [{url = "http://127.0.0.1:8111/hook";}];
        }
      ];
    };
  };

  services.prometheus.alertmanager-ntfy = {
    enable = true;
    settings = {
      http = {
        addr = "127.0.0.1:8111";
      };
      ntfy = {
        baseurl = "https://ntfy.pikpok.xyz";
        notification = {
          topic = "alertmanager";
          priority = ''
            status == "firing" ? "high" : "default"
          '';
          tags = [
            {
              tag = "+1";
              condition = ''status == "resolved"'';
            }
            {
              tag = "rotating_light";
              condition = ''status == "firing"'';
            }
          ];
          templates = {
            title = ''{{ if eq .Status "resolved" }}Resolved: {{ end }}{{ index .Annotations "summary" }}'';
            description = ''{{ index .Annotations "description" }}'';
          };
        };
      };
    };
  };
}
