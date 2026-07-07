{ lib, stdenvNoCC, fetchurl, undmg }:

stdenvNoCC.mkDerivation rec {
  pname = "OpenWhispr";
  version = "1.7.3";

  src = fetchurl {
    url = "https://github.com/OpenWhispr/openwhispr/releases/download/v${version}/OpenWhispr-${version}-arm64.dmg";
    hash = "sha256-GtTrpYpBwt5C3KqX1/+nfZ2ZmnP+cwkJ4/PaF4CyudE=";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -R *.app $out/Applications/
  '';

  meta = with lib; {
    description = "Privacy-first desktop voice dictation & meeting transcription";
    homepage = "https://openwhispr.com/";
    changelog = "https://github.com/OpenWhispr/openwhispr/releases/tag/v${version}";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" "x86_64-darwin" ];
    mainProgram = "OpenWhispr";
  };
}
