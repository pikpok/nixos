{
  services.samba-wsdd.enable = true;
  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = raspberrypi
      netbios name = raspberrypi
      security = user
      hosts allow = 192.168.100. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user

      # Time machine config
      min protocol = SMB2
      server min protocol = SMB2
    '';
    shares = {
      NASNTFS = {
        path = "/mnt/nas-ntfs";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      NAS = {
        path = "/mnt/nas";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      "Time Machine" = {
        path = "/mnt/nas/Time-Machine";
        public = "no";
        writeable = "yes";
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
      };
    };
  };
  users = {
    users.time-machine = {
      isSystemUser = true;
      group = "time-machine";
    };
    groups.time-machine = {};
  };
}
