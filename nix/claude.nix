{ config, pkgs, ... }:

{
  # Claude Code configuration
  home.file.".config/claude/CLAUDE.md" = {
    source = ../config/claude/CLAUDE.md;
  };

  home.file.".config/claude/skills" = {
    source = ../config/claude/skills;
  };

  home.file.".config/claude/commands" = {
    source = ../config/claude/commands;
  };
}
