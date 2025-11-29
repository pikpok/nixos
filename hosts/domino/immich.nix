{lib, ...}: {
  services.immich = {
    enable = true;
    mediaLocation = "/mnt/nas/immich";
    host = "127.0.0.1";
    database = {
      enableVectorChord = true;
      enableVectors = false;
    };
  };

  systemd.services.immich-server.serviceConfig = {
    PrivateDevices = lib.mkForce false;
  };

  users.users.immich.extraGroups = ["share" "video" "render"];
}
