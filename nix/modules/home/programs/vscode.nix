{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    profiles.default = {
      userSettings = {
        # Git
        "git.openRepositoryInParentFolders" = "always";
        "git.confirmSync" = false;
        "git.ignoreRebaseWarning" = true;

        # Terminal
        "terminal.integrated.fontFamily" = "IntoneMono Nerd Font";

        # Editor
        "editor.lineNumbers" = "relative";
        "editor.tabSize" = 2;
        "editor.fontFamily" = "IntoneMono Nerd Font";
        "editor.inlineSuggest.enabled" = true;
        "editor.minimap.enabled" = false;
        "editor.renderWhitespace" = "all";
        "editor.trimAutoWhitespace" = true;
        "editor.linkedEditing" = true;
        "editor.accessibilitySupport" = "off";
        "editor.formatOnSave" = true;
        "editor.codeLens" = false;

        # Workbench
        "workbench.iconTheme" = "catppuccin-mocha";
        "workbench.startupEditor" = "none";
        "workbench.colorTheme" = "Catppuccin Mocha";

        # Files
        "files.associations" = {
          "*.css" = "tailwindcss";
        };

        # Language: Terraform
        "[terraform]" = {
          "editor.tabSize" = 2;
        };

        # Language: JSON
        "[jsonc]" = {
          "editor.defaultFormatter" = "vscode.json-language-features";
        };

        # Language: C++
        "[cpp]" = {
          "editor.defaultFormatter" = "ms-vscode.cpptools";
        };

        # Language: JavaScript/TypeScript
        "[javascript]" = {
          "editor.tabSize" = 2;
          "editor.defaultFormatter" = "biomejs.biome";
        };
        "[typescript]" = {
          "editor.tabSize" = 2;
          "editor.defaultFormatter" = "biomejs.biome";
        };
        "[javascriptreact]" = {
          "editor.tabSize" = 2;
          "editor.defaultFormatter" = "biomejs.biome";
        };
        "[typescriptreact]" = {
          "editor.tabSize" = 2;
          "editor.defaultFormatter" = "biomejs.biome";
        };
        "javascript.updateImportsOnFileMove.enabled" = "always";
        "typescript.updateImportsOnFileMove.enabled" = "always";
        "javascript.referencesCodeLens.enabled" = true;
        "typescript.referencesCodeLens.enabled" = true;

        # Language: YAML
        "[yaml]" = {
          "editor.defaultFormatter" = "bluebrown.yamlfmt";
          "editor.insertSpaces" = true;
          "editor.tabSize" = 2;
          "editor.autoIndent" = "advanced";
          "diffEditor.ignoreTrimWhitespace" = false;
        };
        "[dockercompose]" = {
          "editor.insertSpaces" = true;
          "editor.tabSize" = 2;
          "editor.autoIndent" = "advanced";
          "editor.quickSuggestions" = {
            "other" = true;
            "comments" = false;
            "strings" = true;
          };
          "editor.defaultFormatter" = "redhat.vscode-yaml";
        };
        "[github-actions-workflow]" = {
          "editor.defaultFormatter" = "redhat.vscode-yaml";
        };

        # Language: Go
        "[go]" = {
          "editor.tabSize" = 4;
          "editor.insertSpaces" = false;
        };
        "go.lintTool" = "golangci-lint-v2";
        "go.lintFlags" = [ "--path-mode=abs" "--fast-only" ];
        "go.formatTool" = "custom";
        "go.alternateTools" = {
          "customFormatter" = "golangci-lint-v2";
        };
        "go.formatFlags" = [ "fmt" "--stdin" ];
        "go.toolsManagement.autoUpdate" = true;
        "gopls" = {};

        # Language: Dart
        "[dart]" = {
          "editor.formatOnSave" = true;
          "editor.formatOnType" = true;
          "editor.rulers" = [ 80 ];
          "editor.selectionHighlight" = false;
          "editor.suggestSelection" = "first";
          "editor.tabCompletion" = "onlySnippets";
          "editor.wordBasedSuggestions" = "off";
        };

        # Language: Kotlin
        "[kotlin]" = {
          "editor.defaultFormatter" = "fwcd.kotlin";
        };
        "[kotlinscript]" = {
          "editor.defaultFormatter" = "fwcd.kotlin";
        };

        # Language: XML
        "[xml]" = {
          "editor.defaultFormatter" = "DotJoshJohnson.xml";
        };

        # Language: SQL
        "[sql]" = {
          "editor.defaultFormatter" = "mtxr.sqltools";
        };

        # Bazel
        "bazel.buildifierFixOnFormat" = true;

        # GitHub Copilot
        "github.copilot.enable" = {
          "*" = true;
          "plaintext" = false;
          "markdown" = true;
          "scminput" = false;
        };
        "github.copilot.nextEditSuggestions.enabled" = true;

        # GitHub Pull Requests
        "githubPullRequests.createOnPublishBranch" = "never";
        "githubPullRequests.pullBranch" = "never";

        # vscode-neovim (uses neovim config from ~/.config/nvim)
        "vscode-neovim.neovimExecutablePaths.darwin" = "nvim";
        "vscode-neovim.useWSL" = false;
        "vscode-neovim.compositeKeys" = {
          "jj" = {
            "command" = "vscode-neovim.escape";
          };
          "jk" = {
            "command" = "vscode-neovim.escape";
          };
        };
        "extensions.experimental.affinity" = {
          "asvetliakov.vscode-neovim" = 1;
        };

        # Other
        "jupyter.interactiveWindow.creationMode" = "perFile";
        "cmake.showOptionsMovedNotification" = false;
        "sqliteViewer.maxFileSize" = 4000;
        "diffEditor.maxComputationTime" = 0;
        "diffEditor.ignoreTrimWhitespace" = false;
        "vsicons.dontShowNewVersionMessage" = true;
        "cue.toolsPath" = "\"go tool cue\"";
        "cue.formatTool" = "cue fmt";
        "docker.extension.enableComposeLanguageServer" = false;
        "auto-rename-tag.activationOnLanguage" = [
          "html" "xml" "vue" "javascript" "typescript"
          "javascriptreact" "typescriptreact" "php" "blade"
        ];
        "biome.suggestInstallingGlobally" = false;
      };

      extensions = with pkgs.vscode-extensions; [
        # Git
        eamodio.gitlens
        github.vscode-pull-request-github

        # Languages
        golang.go
        ms-python.python
        ms-python.vscode-pylance
        hashicorp.terraform

        # Web
        bradlc.vscode-tailwindcss
        dbaeumer.vscode-eslint
        biomejs.biome

        # Data
        redhat.vscode-yaml
        tamasfe.even-better-toml

        # Jupyter
        ms-toolsai.jupyter

        # Editor
        asvetliakov.vscode-neovim
        usernamehw.errorlens
        christian-kohler.path-intellisense

        # Theme
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons

        # AI
        github.copilot
        github.copilot-chat

        # Utilities
        ms-vscode-remote.remote-ssh
        ms-azuretools.vscode-docker
        github.vscode-github-actions
      ];
    };
  };
}
