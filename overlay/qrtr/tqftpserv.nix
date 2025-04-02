{ stdenv
, lib
, fetchFromGitHub
, qrtr
, zstd
, meson
, ninja
, pkg-config
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tqftpserv";
  version = "533779cb8a1843581d5422a7f0aae1a35e6ab956";

  nativeBuildInputs = [ meson ninja pkg-config ];
  buildInputs = [ qrtr zstd ];

  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "tqftpserv";
    rev = finalAttrs.version;
    hash = "sha256-KKjEwl6qviDFqhDBU39ug3QBmRtwztHyBWgzvC7GI2w=";
  };

  meta = with lib; {
    description = "Trivial File Transfer Protocol server over AF_QIPCRTR";
    homepage = "https://github.com/linux-msm/tqftpserv";
    license = licenses.bsd3;
    platforms = platforms.aarch64;
  };
})
