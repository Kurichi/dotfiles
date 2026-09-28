return {
  "Kurichi/pr-viewer.nvim",
  -- ローカル開発中（lazy の dev.path = ~/repos/github.com/Kurichi から読む）
  dev = true,
  cmd = "PR",
  keys = {
    -- 番号 or URL を続けて入力する。`:PR open` 単体（現在ブランチの PR）は M4 で対応予定
    { "<leader>gv", ":PR open ", desc = "Open PR in pr-viewer" },
  },
  opts = {},
}
