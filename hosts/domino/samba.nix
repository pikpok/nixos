{pkgs, ...}: {
  services.samba-wsdd.enable = true;
  services.samba = {
    enable = true;
    settings = {
      global = {
        security = "user";
        workgroup = "WORKGROUP";
        "server string" = "domino";
        "netbios name" = "domino";
        "hosts allow" = "192.168.100. 10.77.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      NAS = {
        path = "/mnt/nas";
        browseable = "yes";
        writeable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "valid users" = "share";
      };
      "Time-Machine" = {
        path = "/mnt/nas/Time-Machine";
        public = "no";
        writeable = "yes";
        "valid users" = "share";
        "fruit:aapl" = "yes";
        "fruit:time machine" = "yes";
        "fruit:model" = "TimeCapsule8,119";
        "fruit:metadata" = "stream";
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:nfs_aces" = "no";
        "fruit:encoding" = "private";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        "vfs objects" = "catia fruit streams_xattr";
        "fruit:time machine max size" = "1T";
      };
    };
  };
  users = {
    groups.share = {
      gid = 993;
    };
    users.share = {
      uid = 994;
      isSystemUser = true;
      group = "share";
    };
    users.pikpok.extraGroups = ["share"];
  };

  sops.secrets."samba-password" = {
    sopsFile = ../../secrets/domino/samba-password.yaml;
  };

  # Okay, this is ugly. But we somehow have to make sure we run this script
  # after system.activationScripts.setupSecretsForUsers from sops-nix.
  # Prepending a zzz_ to the script name ensures that it runs last.
  system.activationScripts.zzz_samba_user_create = ''
    smb_password=$(cat /run/secrets/samba-password)
    echo -e "$smb_password\n$smb_password\n" | ${pkgs.samba}/bin/smbpasswd -a -s share
  '';
}
