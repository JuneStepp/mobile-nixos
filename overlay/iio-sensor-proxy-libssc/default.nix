{
  iio-sensor-proxy,
  fetchFromGitLab,
  lib,
  sscSupport ? true,
  libssc,
  libqmi,
  protobufc,
}:

iio-sensor-proxy.overrideAttrs (old: rec {
  versoin = "unstable-2024-06-05-ssc";
  name = "${old.pname}-${versoin}";
  # https://gitlab.freedesktop.org/hadess/iio-sensor-proxy/-/tree/ssc
  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "hadess";
    repo = old.pname;
    rev = "49e4f30e95d12e596cf501b994101ad20a23058e";
    hash = "sha256-OnUPxc/NLgQ5eihzvgFXssFqdRECMIj0J6h0sZMt1DU=";
  };
  mesonFlags = old.mesonFlags ++ [ (lib.mesonBool "ssc-support" sscSupport) ];
  # nativeBuildInputs = old.nativeBuildInputs ++ lib.optional sscSupport protobufc;
  buildInputs =
    old.buildInputs
    ++ lib.optionals sscSupport [
      libssc
      libqmi
      protobufc
    ];
})
