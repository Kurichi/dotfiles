{ profile, ... }:
{
  # Environment variables
  home.sessionVariables = {
    # AI Tools
    CODEX_HOME = "$HOME/.config/codex";
    CLAUDE_CONFIG_DIR = "$HOME/.config/claude";
    CLAUDE_CODE_NO_FLICKER = "1";
    GEMINI_CLI_HOME = "$HOME/.config";  # ~/.config/.gemini/ に設定保存
    # Git
    GIT_CONFIG_GLOBAL = "$HOME/.config/git/config";
    # pnpm
    PNPM_HOME = "$HOME/.local/share/pnpm";
  } // (if profile ? sshAuthSock then {
    SSH_AUTH_SOCK = profile.sshAuthSock;
  } else {});
}
