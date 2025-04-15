{ stdenv, lib, fetchFromGitHub, udev, qrtr, qmic }:

stdenv.mkDerivation (finalAttrs: {
  pname = "rmtfs";
  version = "1.0";

  buildInputs = [ udev qrtr qmic ];

  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "rmtfs";
    rev = "v${finalAttrs.version}";
    hash = "sha256-00KOjdkwcAER261lleSl7OVDEAEbDyW9MWxDd0GI8KA=";
  };

  installFlags = [ "prefix=$(out)" ];

  postInstall = ''
    # https://gitlab.postmarketos.org/postmarketOS/pmaports/-/blob/master/modem/rmtfs/udev.rules
    install -Dm644 ${./rmtfs-udev.rules} $out/etc/udev/rules.d/65-${finalAttrs.pname}.rules
  '';

  meta = with lib; {
    description = "Qualcomm Remote Filesystem Service";
    homepage = "https://github.com/linux-msm/rmtfs";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
})
