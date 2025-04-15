{
  stdenv,
  fetchFromGitea,
  lib,
  meson,
  ninja,
  pkg-config,
  libqmi,
  glib,
  protobufc,
  python3,
  protobuf,
  qrtr,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libssc";
  version = "0.2.2";
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "DylanVanAssche";
    repo = "libssc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-vc3phLAURKXAVD/o4uiGkBtJ3wsbLEfkwygMltEhqug=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    protobufc
    # Tests
    protobuf
    python3.pkgs.pygobject3
    qrtr
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
    platforms = platforms.linux;
  };
})
