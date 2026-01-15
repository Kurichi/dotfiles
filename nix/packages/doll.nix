{ lib, stdenvNoCC, fetchurl, _7zz }:

stdenvNoCC.mkDerivation rec {
  pname = "doll";
  version = "0.0.9.2";

  src = fetchurl {
    url = "https://github.com/xiaogdgenuine/Doll/releases/download/v${version}/Doll.${version}.dmg";
    sha256 = "sha256-+ctQuR/BI9A9ZMyeva+UB/6XZ5bNuaX/zYmk+dScTcU=";
  };

  nativeBuildInputs = [ _7zz ];

  sourceRoot = "Doll.app";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r . $out/Applications/Doll.app
    runHook postInstall
  '';

  meta = with lib; {
    description = "A menubar app to show app badges";
    homepage = "https://github.com/xiaogdgenuine/Doll";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}
