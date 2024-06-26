{pkgs, ...}: {
  # TODO: Intel Quick Sync works, but not in Photoprism for some reason. Need to debug it further
  # Also: maybe some of this setup is not needed?

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override {enableHybridCodec = true;};
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vaapiVdpau
      libvdpau-va-gl
      vaapiIntel
      intel-ocl
      vpl-gpu-rt
    ];
  };
  environment.sessionVariables = {LIBVA_DRIVER_NAME = "iHD";}; # Force intel-media-driver
}
