final: prev: {
  # nixpkgs 未収録のパッケージ
  k1low-mo = final.callPackage ./pkgs/k1low-mo.nix { };

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
