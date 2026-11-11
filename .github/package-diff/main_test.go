package main

import "testing"

func TestIsBreaking(t *testing.T) {
	tests := []struct {
		old, new string
		want     bool
	}{
		{"1.16.6", "1.17.1", false},
		{"1.16.6", "2.0.0", true},
		{"0.13.4", "0.13.5", false},
		{"0.13.4", "0.14.0", true},
		{"0-unstable-2026-10-01", "0-unstable-2026-11-01", false},
		{"583.0.0", "592.0.0", true},
		{"v2.1.0", "2.3.0", false},
	}
	for _, tt := range tests {
		if got := isBreaking(tt.old, tt.new); got != tt.want {
			t.Errorf("isBreaking(%q, %q) = %v, want %v", tt.old, tt.new, got, tt.want)
		}
	}
}

func TestDiff(t *testing.T) {
	base := map[string]string{"gh": "2.103.2", "terraform": "1.16.6", "google-cloud-sdk": "583.0.0", "old": "1.0.0"}
	head := map[string]string{"gh": "2.103.2", "terraform": "2.0.0", "google-cloud-sdk": "592.0.0", "new": "1.0.0"}

	got := diff(base, head)
	want := []change{
		{Name: "terraform", Old: "1.16.6", New: "2.0.0", Major: true},
		{Name: "google-cloud-sdk", Old: "583.0.0", New: "592.0.0"},
		{Name: "new", New: "1.0.0"},
		{Name: "old", Old: "1.0.0"},
	}
	if len(got) != len(want) {
		t.Fatalf("diff() = %+v, want %+v", got, want)
	}
	for i := range want {
		if got[i] != want[i] {
			t.Errorf("diff()[%d] = %+v, want %+v", i, got[i], want[i])
		}
	}
}
