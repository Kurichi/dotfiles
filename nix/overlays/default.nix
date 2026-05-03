_final: prev: {
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
