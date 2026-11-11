// package-diff は 2 つの flake の home.packages を評価し、バージョン差分を Markdown で出力する。
// メジャー（0.x はマイナー）が変わったパッケージ数を標準出力に出す。
//
//	usage: package-diff <base-flake> <head-flake> <output.md>
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"maps"
	"os"
	"os/exec"
	"regexp"
	"slices"
	"strings"
)

var profiles = []string{"personal", "work"}

// メジャー判定から外すパッケージ（毎週メジャー/0.x マイナーが上がるもの）
var ignoreMajor = []string{"google-cloud-sdk", "gemini-cli"}

const marker = "<!-- package-version-diff -->"

const applyExpr = `users: builtins.concatMap (u: map (p:
  let d = builtins.parseDrvName (p.name or ""); in
  { name = p.pname or d.name; version = p.version or d.version; }
) u.home.packages) (builtins.attrValues users)`

type change struct {
	Name     string
	Old, New string // 空文字は追加/削除を表す
	Major    bool
}

func main() {
	if len(os.Args) != 4 {
		fmt.Fprintln(os.Stderr, "usage: package-diff <base-flake> <head-flake> <output.md>")
		os.Exit(2)
	}
	if err := run(os.Args[1], os.Args[2], os.Args[3]); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run(baseFlake, headFlake, out string) error {
	base, err := versions(baseFlake)
	if err != nil {
		return err
	}
	head, err := versions(headFlake)
	if err != nil {
		return err
	}

	changes := diff(base, head)
	if err := os.WriteFile(out, []byte(render(changes)), 0o644); err != nil {
		return err
	}
	fmt.Println(countMajor(changes))
	return nil
}

func versions(flake string) (map[string]string, error) {
	result := map[string]string{}
	for _, profile := range profiles {
		attr := fmt.Sprintf("%s#darwinConfigurations.%s.config.home-manager.users", flake, profile)
		cmd := exec.Command("nix", "eval", "--json", attr, "--apply", applyExpr)
		cmd.Stderr = os.Stderr
		stdout, err := cmd.Output()
		if err != nil {
			return nil, fmt.Errorf("nix eval %s: %w", attr, err)
		}
		var pkgs []struct{ Name, Version string }
		if err := json.Unmarshal(stdout, &pkgs); err != nil {
			return nil, fmt.Errorf("parse nix eval output: %w", err)
		}
		for _, p := range pkgs {
			result[p.Name] = p.Version
		}
	}
	return result, nil
}

func diff(base, head map[string]string) []change {
	names := slices.Sorted(maps.Keys(base))
	for name := range head {
		if _, ok := base[name]; !ok {
			names = append(names, name)
		}
	}
	slices.Sort(names)

	var changes []change
	for _, name := range names {
		from, to := base[name], head[name]
		if from == to {
			continue
		}
		changes = append(changes, change{
			Name:  name,
			Old:   from,
			New:   to,
			Major: from != "" && to != "" && !slices.Contains(ignoreMajor, name) && isBreaking(from, to),
		})
	}
	// メジャー変更を先頭に並べる
	slices.SortStableFunc(changes, func(a, b change) int {
		switch {
		case a.Major && !b.Major:
			return -1
		case !a.Major && b.Major:
			return 1
		}
		return 0
	})
	return changes
}

var numberRe = regexp.MustCompile(`[0-9]+`)

// isBreaking は 0.x ならマイナー、それ以外はメジャーが変わったかを返す。unstable 版は判定しない。
func isBreaking(from, to string) bool {
	if strings.Contains(from, "unstable") || strings.Contains(to, "unstable") {
		return false
	}
	return slices.Compare(compatKey(from), compatKey(to)) != 0
}

func compatKey(version string) []string {
	parts := numberRe.FindAllString(version, 2)
	if len(parts) == 0 {
		return nil
	}
	if strings.TrimLeft(parts[0], "0") == "" {
		return parts
	}
	return parts[:1]
}

func countMajor(changes []change) int {
	n := 0
	for _, c := range changes {
		if c.Major {
			n++
		}
	}
	return n
}

func render(changes []change) string {
	var b bytes.Buffer
	fmt.Fprintln(&b, marker)
	fmt.Fprintln(&b, "## パッケージのバージョン差分")
	fmt.Fprintln(&b)
	if len(changes) == 0 {
		fmt.Fprintln(&b, "home.packages のバージョン変更はありません。")
		return b.String()
	}
	if n := countMajor(changes); n > 0 {
		fmt.Fprintf(&b, "⚠️ メジャーアップデートが %d 件あります。確認後 `allow-major` ラベルを付けるとマージされます。\n\n", n)
	}
	fmt.Fprintln(&b, "| | パッケージ | 変更前 | 変更後 |")
	fmt.Fprintln(&b, "|---|---|---|---|")
	for _, c := range changes {
		mark := ""
		if c.Major {
			mark = "⚠️"
		}
		fmt.Fprintf(&b, "| %s | `%s` | %s | %s |\n", mark, c.Name, orDefault(c.Old, "（追加）"), orDefault(c.New, "（削除）"))
	}
	return b.String()
}

func orDefault(s, def string) string {
	if s == "" {
		return def
	}
	return s
}
