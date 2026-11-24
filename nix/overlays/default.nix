final: prev: {
  # nixpkgs 未収録のパッケージ
  datadog-pup = final.callPackage ./pkgs/datadog-pup.nix { };
  displayplacer = final.callPackage ./pkgs/displayplacer.nix { };

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (_pyFinal: pyPrev:
      prev.lib.optionalAttrs (pyPrev ? python-lsp-server) {
        # WORKAROUND: upstream python-lsp/python-lsp-server#605
        # pytest teardown が closed stream に log を書きにいって落ちるため
        # checkPhase をスキップする。upstream / nixpkgs 修正後に削除する。
        python-lsp-server = pyPrev.python-lsp-server.overridePythonAttrs (_: {
          doCheck = false;
        });
      }
    )
  ];
}
