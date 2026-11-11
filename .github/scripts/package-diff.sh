#!/usr/bin/env bash
# 2 つの flake の home.packages を評価し、バージョン差分を Markdown で出力する。
# usage: package-diff.sh <base-flake-dir> <head-flake-dir> <output.md>
# メジャー（0.x はマイナー）が変わったパッケージ数を標準出力に出す。
set -euo pipefail

base_dir=$1
head_dir=$2
out=$3

# メジャー判定から外すパッケージ（毎週メジャー/0.x マイナーが上がるもの）
ignore_major='["google-cloud-sdk", "gemini-cli"]'

apply='users: builtins.concatMap (u: map (p:
  let d = builtins.parseDrvName (p.name or ""); in
  { name = p.pname or d.name; version = p.version or d.version; }
) u.home.packages) (builtins.attrValues users)'

versions() {
  local dir=$1
  for profile in personal work; do
    nix eval --json "$dir#darwinConfigurations.$profile.config.home-manager.users" --apply "$apply"
  done | jq -s 'add | map({key: .name, value: .version}) | from_entries'
}

rows=$(jq -n --argjson base "$(versions "$base_dir")" --argjson head "$(versions "$head_dir")" --argjson ignore "$ignore_major" '
  # 0.x はマイナーを、それ以外はメジャーを互換性の境界とみなす。unstable 版は判定しない。
  def key: [scan("[0-9]+") | tonumber] as $p
    | if ($p[0] // 0) == 0 then $p[0:2] else $p[0:1] end;
  def breaking($o; $n): ($o | test("unstable") | not) and ($n | test("unstable") | not)
    and ($o | key) != ($n | key);

  [($base + $head) | keys[] as $k
    | {name: $k, old: $base[$k], new: $head[$k]}
    | select(.old != .new)
    | .major = (.old != null and .new != null and (.name | IN($ignore[]) | not) and breaking(.old; .new))]
  | sort_by((.major | not), .name)
')

jq -r '
  (map(select(.major)) | length) as $majors
  | "<!-- package-version-diff -->",
    "## パッケージのバージョン差分",
    "",
    if length == 0 then "home.packages のバージョン変更はありません。"
    else
      (if $majors > 0 then
         "⚠️ メジャーアップデートが \($majors) 件あります。確認後 `allow-major` ラベルを付けるとマージされます。\n"
       else empty end),
      "| | パッケージ | 変更前 | 変更後 |",
      "|---|---|---|---|",
      (.[] | "| \(if .major then "⚠️" else "" end) | `\(.name)` | \(.old // "（追加）") | \(.new // "（削除）") |")
    end
' <<<"$rows" > "$out"

jq 'map(select(.major)) | length' <<<"$rows"
