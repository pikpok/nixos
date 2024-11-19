{pkgs, ...}: let
  teslamateDashboards = pkgs.fetchgit {
    url = "https://github.com/teslamate-org/teslamate";
    rev = "v1.31.1";
    sparseCheckout = ["grafana/dashboards"];
    sha256 = "sha256-Sc36RgSTYDdKrRFEmHDT+GxogOGd27KzxJJIR1lUSPA=";
  };

  teslamateCustomDashboards = pkgs.fetchgit {
    url = "https://github.com/jheredianet/Teslamate-CustomGrafanaDashboards";
    rev = "v2024.7.11";
    sparseCheckout = ["dashboards"];
    sha256 = "sha256-MnGeeV2jIu/f0h+9AYaC9w4FoDKS91be/idwA+N4YsU=";
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
                path = teslamateDashboards + "/grafana/dashboards";
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
              database = "teslamate";
              user = "teslamate";
              jsonData = {sslmode = "disable";};
            }
          ];
        };
      };
    };
  };
}
