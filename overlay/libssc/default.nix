{
  stdenv,
  fetchgit,
  lib,
  meson,
  ninja,
  pkg-config,
  libqmi,
  glib,
  protobufc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libssc";
  version = "0.1.5";
  src = fetchgit {
    url = "https://codeberg.org/DylanVanAssche/libssc.git";
    rev = finalAttrs.version;
    hash = "sha256-XcVNmUVIoA5JEZmX0FoQvTSxWuDcK3Vi8yq/kt9Zddo=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    protobufc
  ];

  buildInputs = [
    libqmi
    glib
    protobufc
  ];

  meta = with lib; {
    description = "Library for exposing Qualcomm Sensor Core sensors to Linux";
    homepage = "https://libssc.dylanvanassche.be";
    license = licenses.gpl3Plus;
    platforms = platforms.aarch64;
  };
})
