{ profile, ... }:
{
  # Environment variables
  home.sessionVariables = {
    # AI Tools
    CODEX_HOME = "$HOME/.config/codex";
    CLAUDE_CONFIG_DIR = "$HOME/.config/claude";
    GEMINI_CLI_HOME = "$HOME/.config";  # ~/.config/.gemini/ に設定保存
    # pnpm
    PNPM_HOME = "$HOME/.local/share/pnpm";
  } // (if profile ? sshAuthSock then {
    SSH_AUTH_SOCK = profile.sshAuthSock;
  } else {});
}
