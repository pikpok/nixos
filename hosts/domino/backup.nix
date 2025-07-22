{
  pkgs,
  config,
  lib,
  ...
}: {
  sops.secrets."borgmatic" = {
    sopsFile = ../../secrets/${config.networking.hostName}/borgmatic.env;
    format = "dotenv";
  };

  systemd.services."borgmatic" = {
    overrideStrategy = "asDropin";
    serviceConfig.EnvironmentFile = "/run/secrets/borgmatic";
  };

  services.borgmatic = {
    enable = true;
    # env variables are not present when doing config check at buildtime
    enableConfigCheck = false;
    configurations = {
      nas = {
        keep_daily = 7;
        keep_monthly = 6;
        source_directories = [
          "/mnt/nas/Music"
          "/mnt/nas/Photos"
        ];
        repositories = [
          {
            path = "$\{HETZNER_NAS_REPO_PATH\}";
            label = "hetzner";
          }
        ];
        healthchecks = {
          ping_url = "$\{HEALTHCHECKS_NAS_PING_URL\}";
        };
      };
      domino = {
        keep_daily = 7;
        keep_monthly = 6;
        source_directories = [
          "/var/lib"
        ];
        exclude_patterns = [
          "/var/lib/containers"
        ];
        repositories = [
          {
            path = "$\{HETZNER_DOMINO_REPO_PATH\}";
            label = "hetzner";
          }
        ];
        postgresql_databases = lib.mkIf config.services.postgresql.enable [
          {
            name = "all";
            username = "postgres";
            pg_dump_command = "${pkgs.postgresql_16}/bin/pg_dumpall";
          }
        ];
        mariadb_databases = lib.mkIf config.services.mysql.enable [
          {
            name = "all";
            username = "root";
            mariadb_dump_command = "${config.services.mysql.package}/bin/mariadb-dump";
            mariadb_command = "${config.services.mysql.package}/bin/mariadb";
            format = "sql";
          }
        ];
        healthchecks = {
          ping_url = "$\{HEALTHCHECKS_DOMINO_PING_URL\}";
        };
      };
    };
  };
}
