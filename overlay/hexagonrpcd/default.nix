{
  stdenv,
  lib,
  fetchFromGitHub,
  meson,
  ninja,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hexagonrpcd";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "hexagonrpc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-OC6wXBCIW4XznWG0zzxRK3BzWMVK2Jq/gTL36sJV1PE=";
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
