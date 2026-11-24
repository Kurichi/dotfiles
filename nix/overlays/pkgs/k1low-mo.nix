{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  installShellFiles,
}:

# Markdown をブラウザで開くビューア (https://github.com/k1LoW/mo)
#
# - nixpkgs の `mo` は別物（Mustache templates for Bash）なので属性名を k1low-mo にしている
# - ソースビルドはフロントエンド（pnpm）のビルドを伴うため、公式リリースのビルド済みバイナリを使う
# - 更新時は version と hash を書き換える。sha256 はリリースの checksums.txt に載っている
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "k1low-mo";
  version = "1.8.2";

  src = fetchurl {
    url = "https://github.com/k1LoW/mo/releases/download/v${finalAttrs.version}/mo_v${finalAttrs.version}_darwin_arm64.zip";
    hash = "sha256-TCloqasC82h+qBlhCFwQbyMqLGO6UIjsgZs5VaFCTF4=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    unzip
    installShellFiles
  ];

  # 署名済みバイナリを書き換えない
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 mo $out/bin/mo
    runHook postInstall
  '';

  # Homebrew formula と同様、バイナリ自身から補完スクリプトを生成する
  postInstall = lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
    export HOME=$TMPDIR
    installShellCompletion --cmd mo \
      --bash <($out/bin/mo completion bash) \
      --fish <($out/bin/mo completion fish) \
      --zsh <($out/bin/mo completion zsh)
  '';

  meta = {
    description = "Markdown viewer that opens .md files in a browser";
    homepage = "https://github.com/k1LoW/mo";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "mo";
  };
})
