{
  config,
  lib,
  pkgs,
  ...
}: let
  # Hermes v0.23.3-desktop; bump the digest deliberately.
  image = "docker.io/nousresearch/hermes-agent@sha256:5f587d1c036e551f57f1c706c460b41a4f48de0c4763e5865343eafd3950a2bc";
  dataDir = "/var/lib/hermes";
  chrome = "${pkgs.google-chrome}/bin/google-chrome-stable";
  # `ssh mac` from the container: a shell on the owner's Mac.
  macSshConfig = pkgs.writeText "mac.conf" ''
    Host mac
      HostName pikpok-mbp.lan
      User pikpok
      IdentityFile /opt/data/.ssh/id_mac
      UserKnownHostsFile /etc/hermes/mac-known-hosts
      HostKeyAlias pikpok-mbp
      BatchMode yes
      ServerAliveInterval 30
  '';
  # Force-install uBlock Origin Lite and Consent-O-Matic from the Web Store.
  chromePolicy = (pkgs.formats.json {}).generate "hermes-chrome-policy.json" {
    ExtensionInstallForcelist = map (id: "${id};https://clients2.google.com/service/update2/crx") [
      "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
      "mdjildafknihdffpkfmmpnpoiajfjnjd" # Consent-O-Matic
    ];
  };
  # Managed settings: they override /opt/data/config.yaml and can't be changed from chat.
  hermesConfig = (pkgs.formats.yaml {}).generate "hermes-config.yaml" {
    model = {
      provider = "openai-codex";
      default = "gpt-6-astra-900k";
    };
    # browser_exec and Bot Screen's Browser icon run regular Google Chrome
    # (nixpkgs, mounted from /nix/store) in a visible window, on
    # /opt/data/bot-desktop/browser-profile.
    browser = {
      executable_path = chrome;
      headed = true;
      allow_private_urls = true;
    };
    # Start Bot Screen (Xfce desktop over VNC) on the first headed browser use.
    bot_desktop.auto_start = true;
    # The Mac's desktop: Cua Driver's MCP server over SSH, which starts the
    # signed CuaDriver.app there.
    mcp_servers.mac = {
      command = "/usr/bin/ssh";
      args = ["-T" "mac" "CUA_DRIVER_RS_TELEMETRY_ENABLED=0 /Applications/CuaDriver.app/Contents/MacOS/cua-driver mcp"];
      connect_timeout = 30;
      timeout = 60;
    };
    # Served at https://hermes.pikpok.xyz by Traefik through Podman's port forward.
    dashboard = {
      public_url = "https://hermes.pikpok.xyz";
      trusted_proxies = ["10.88.0.1"];
    };
  };
in {
  # Matches the image's hermes user, which owns the state directory.
  users.groups.hermes.gid = 10000;
  users.users.hermes = {
    isSystemUser = true;
    uid = 10000;
    group = "hermes";
    home = dataDir;
  };
  systemd.tmpfiles.rules = ["d ${dataDir} 0700 hermes hermes -"];
  # Each start is a new container (new hostname), and Hermes refuses a browser
  # profile whose SingletonLock names another host. After the module's
  # `podman rm -f hermes` no browser holds the profile, so the lock is stale.
  systemd.services.podman-hermes.serviceConfig.ExecStartPre = lib.mkAfter [
    "${pkgs.coreutils}/bin/rm -f ${dataDir}/bot-desktop/browser-profile/SingletonLock ${dataDir}/bot-desktop/browser-profile/SingletonCookie ${dataDir}/bot-desktop/browser-profile/SingletonSocket"
  ];

  # Telegram bot token/allowlist and dashboard login.
  # The ChatGPT login lives in /var/lib/hermes/auth.json.
  sops.secrets.hermes = {
    sopsFile = ../../secrets/domino/hermes.env;
    format = "dotenv";
    owner = "hermes";
    group = "hermes";
    mode = "0400";
    restartUnits = ["podman-hermes.service"];
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.hermes = {
      inherit image;
      cmd = ["gateway" "run"];
      # Dashboard, for Traefik (hermes.pikpok.xyz).
      ports = ["127.0.0.1:9119:9119"];
      environment = {
        HERMES_DASHBOARD = "1";
        TZ = "Europe/Warsaw";
      };
      volumes = [
        "${dataDir}:/opt/data"
        # Google Chrome and its dependencies.
        "/nix/store:/nix/store:ro"
        "${chromePolicy}:/etc/opt/chrome/policies/managed/hermes.json:ro"
        "${hermesConfig}:/etc/hermes/config.yaml:ro"
        "${config.sops.secrets.hermes.path}:/etc/hermes/.env:ro"
        "${./hermes/mac-known-hosts}:/etc/hermes/mac-known-hosts:ro"
        "${macSshConfig}:/etc/ssh/ssh_config.d/mac.conf:ro"
        "${./hermes/SOUL.md}:/opt/data/SOUL.md:ro"
        # Hermes only launches Chromium without its nested sandbox when it sees
        # Docker's marker; Podman doesn't create one.
        "${pkgs.writeText "dockerenv" ""}:/.dockerenv:ro"
      ];
      extraOptions = ["--shm-size=1g"];
    };
  };
}
