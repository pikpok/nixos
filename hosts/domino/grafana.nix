{
  pkgs,
  inputs,
  ...
}: let
  teslamateDashboards = pkgs.fetchgit {
    url = "https://github.com/teslamate-org/teslamate";
    rev = inputs.teslamate.shortRev;
    sparseCheckout = ["grafana/dashboards"];
    sha256 = "sha256-j91yu8jNEpFSFritUyl6m+g6S/3lhimlt5JzMJvYT58=";
  };

  teslamateDefaultDashboards = pkgs.runCommand "teslamate-default-dashboards" {} ''
    mkdir -p $out/grafana/dashboards
    cp ${teslamateDashboards}/grafana/dashboards/*.json $out/grafana/dashboards/
  '';

  teslamateCustomDashboards = pkgs.fetchgit {
    url = "https://github.com/jheredianet/Teslamate-CustomGrafanaDashboards";
    rev = "v2026.4.2";
    sparseCheckout = ["dashboards"];
    sha256 = "sha256-2ObwieKKT2VRJtePmYqB2rkcBJcrCJ8PZ1iJ32eVjI8=";
  };
in {
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        root_url = "https://grafana.pikpok.xyz/";
      };
      # TODO: replace with a proper secret
      security.secret_key = "$__file{/var/lib/grafana/secret-key}";
    };
    provision = {
      dashboards = {
        settings = {
          apiVersion = 1;
          providers = [
            {
              name = "teslamate";
              type = "file";
              folder = "TeslaMate";
              folderUid = "Nr4ofiDZk";
              options = {
                path = teslamateDefaultDashboards + "/grafana/dashboards";
                foldersFromFilesStructure = false;
              };
            }
            {
              name = "teslamate_internal";
              type = "file";
              folder = "Internal";
              folderUid = "Nr5ofiDZk";
              options = {
                path = teslamateDashboards + "/grafana/dashboards/internal";
              };
            }
            {
              name = "teslamate_reports";
              type = "file";
              folder = "Reports";
              folderUid = "Nr6ofiDZk";
              options = {
                path = teslamateDashboards + "/grafana/dashboards/reports";
              };
            }
            {
              name = "TeslamateCustomDashboards";
              type = "file";
              folder = "TeslaMate Custom Dashboards";
              folderUid = "jchmTmCuGrDa";
              options = {
                path = teslamateCustomDashboards + "/dashboards";
              };
            }
          ];
        };
      };
      datasources = {
        settings = {
          apiVersion = 1;
          datasources = [
            {
              name = "TeslaMate";
              type = "postgres";
              url = "/var/run/postgresql";
              user = "teslamate";
              jsonData = {
                postgresVersion = 1500;
                sslmode = "disable";
                database = "teslamate";
              };
            }
          ];
        };
      };
    };
  };
}
