{
  lib,
  pkgs,
  ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "valent";
  version = "1.0.0.alpha";

  src = pkgs.fetchFromGitHub {
    owner = "andyholmes";
    repo = "valent";
    rev = "bd1126818bb8f123ceafc6a449cf26102f75293e";
    hash = "sha256-YLvuPBaykeORLBj1cxT8KFYD02KaK3KuAKZNUf8QhMs=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
    gtk4
    glib
    desktop-file-utils
    wrapGAppsHook4

    glib
    glib-networking
    gnutls
    json-glib
    libpeas
    sqlite
    evolution-data-server-gtk4
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    libpulseaudio
    desktop-file-utils
    libportal-gtk4
    libsysprof-capture
  ];

  buildInputs = with pkgs; [
    glib
    gtk4
    libadwaita
    openssl
    alsa-lib
    libpulseaudio
  ];

  meta = with lib; {
    description = "Valent";
    homepage = "https://github.com/andyholmes/valent";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
