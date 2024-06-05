{
  stdenv,
  lib,
  fetchFromGitLab,
  meson,
  ninja,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hexagonrpcd";
  version = "0.3.0";

  src = fetchFromGitLab {
    owner = "flamingradian";
    repo = "sensh";
    rev = "v${finalAttrs.version}";
    hash = "sha256-BwA3+aKO5CJYmSYGybLGu64zOyM1MZmnVf3zIlSnlO0=";
  };

  preConfigure = ''
    cd fastrpc
  '';

  nativeBuildInputs = [
    meson
    ninja
  ];

  meta = with lib; {
    mainProgram = "hexagonrpcd";
    description = "Server for FastRPC remote procedure calls from Qualcomm DSPs";
    homepage = "https://gitlab.com/flamingradian/sensh";
    license = licenses.gpl3Plus;
    platforms = platforms.aarch64;
  };
})
