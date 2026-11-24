{
  lib,
  stdenvNoCC,
  fetchurl,
  installShellFiles,
}:

# Datadog API CLI (https://github.com/datadog-labs/pup)
#
# - nixpkgs の `pup` は別物（ericchiang/pup: HTML パーサ）なので属性名を datadog-pup にしている
# - nixpkgs 未収録のため、公式リリースのビルド済みバイナリを使う
# - 更新時は version と hash を書き換える。sha256 はリリースの checksums.txt
#   （datadog-labs/homebrew-pack の Formula/pup.rb にも同じ値）に載っている
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "datadog-pup";
  version = "2.6.1";

  src = fetchurl {
    url = "https://github.com/datadog-labs/pup/releases/download/v${finalAttrs.version}/pup_${finalAttrs.version}_Darwin_arm64.tar.gz";
    hash = "sha256-icmRrdSB3XRC/mtYe4L0OdQc5I3jXbk1r5iqGWyIHKs=";
  };

  # tarball がディレクトリを含まずトップレベルにファイルを展開するため
  sourceRoot = ".";

  nativeBuildInputs = [ installShellFiles ];

  # 署名済みバイナリを書き換えない
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 pup $out/bin/pup
    runHook postInstall
  '';

  # Homebrew formula と同様、バイナリ自身から補完スクリプトを生成する
  postInstall = lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
    installShellCompletion --cmd pup \
      --bash <($out/bin/pup completions bash) \
      --fish <($out/bin/pup completions fish) \
      --zsh <($out/bin/pup completions zsh)
  '';

  meta = {
    description = "Datadog API CLI";
    homepage = "https://github.com/datadog-labs/pup";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "pup";
  };
})
