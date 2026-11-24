{
  lib,
  stdenvNoCC,
  fetchurl,
}:

# マルチディスプレイの解像度・配置を CLI から設定するツール (https://github.com/jakehilborn/displayplacer)
#
# - nixpkgs 未収録
# - ソースは SDK に含まれない private framework（SkyLight 等）にリンクするため、
#   公式リリースのビルド済みバイナリを使う
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "displayplacer";
  version = "1.4.0";

  src = fetchurl {
    url = "https://github.com/jakehilborn/displayplacer/releases/download/v${finalAttrs.version}/displayplacer-apple-v${lib.replaceStrings [ "." ] [ "" ] finalAttrs.version}";
    hash = "sha256-BXLD0pGOR8fguddyOQeGTi6itTudOwI3l2n//PRPfqA=";
  };

  dontUnpack = true;

  # 署名済みバイナリを書き換えない
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/displayplacer
    runHook postInstall
  '';

  meta = {
    description = "macOS command line utility to configure multi-display resolutions and arrangements";
    homepage = "https://github.com/jakehilborn/displayplacer";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "displayplacer";
  };
})
