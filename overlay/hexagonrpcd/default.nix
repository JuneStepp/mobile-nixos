{
  stdenv,
  lib,
  fetchFromGitHub,
  meson,
  ninja,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hexagonrpcd";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "hexagonrpc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-v8BRorYXvRCDE5BmXx2QFWp4H+TMhGf6/te4vav5Rmc=";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  meta = with lib; {
    mainProgram = "hexagonrpcd";
    description = "Server for FastRPC remote procedure calls from Qualcomm DSPs";
    homepage = "https://github.com/linux-msm/hexagonrpc";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
})
