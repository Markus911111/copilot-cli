# GitHub Copilot CLI Integration Guide

This guide provides comprehensive instructions for integrating GitHub Copilot CLI with various tools, environments, and workflows.

## Table of Contents

- [Terminal Integration](#terminal-integration)
- [VS Code Integration](#vs-code-integration)
- [MCP Server Configuration](#mcp-server-configuration)
- [Shell Completions](#shell-completions)
- [Git Hooks Integration](#git-hooks-integration)
- [CI/CD Integration](#cicd-integration)
- [Custom Workflows](#custom-workflows)

---

## Terminal Integration

### Bash

Add to your `~/.bashrc` or `~/.bash_profile`:

```bash
# GitHub Copilot CLI alias
alias ai='copilot'

# Quick prompt mode
alias aip='copilot -p'

# Enable terminal integration
eval "$(copilot /terminal-setup bash)"
```

### Zsh

Add to your `~/.zshrc`:

```zsh
# GitHub Copilot CLI alias
alias ai='copilot'

# Quick prompt mode
alias aip='copilot -p'

# Enable terminal integration
eval "$(copilot /terminal-setup zsh)"
```

### PowerShell

Add to your PowerShell profile (`$PROFILE`):

```powershell
# GitHub Copilot CLI alias
Set-Alias -Name ai -Value copilot

# Quick prompt mode
function aip { copilot -p $args }

# Enable terminal integration
Invoke-Expression (copilot /terminal-setup powershell)
```

### Fish

Add to your `~/.config/fish/config.fish`:

```fish
# GitHub Copilot CLI alias
alias ai='copilot'
alias aip='copilot -p'

# Enable terminal integration
copilot /terminal-setup fish | source
```

---

## VS Code Integration

### MCP Configuration Sharing

Copilot CLI can leverage VS Code's MCP configuration. Create or update `~/.vscode/mcp.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "type": "local",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/project"]
    },
    "github": {
      "type": "local",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### Workspace Integration

In your VS Code workspace settings (`.vscode/settings.json`):

```json
{
  "terminal.integrated.env.linux": {
    "COPILOT_WORKSPACE": "${workspaceFolder}"
  },
  "terminal.integrated.env.osx": {
    "COPILOT_WORKSPACE": "${workspaceFolder}"
  },
  "terminal.integrated.env.windows": {
    "COPILOT_WORKSPACE": "${workspaceFolder}"
  }
}
```

---

## MCP Server Configuration

### Local Configuration

Create `~/.copilot/mcp-config.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "type": "local",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "${HOME}/projects"],
      "tools": ["*"]
    },
    "git": {
      "type": "local",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git"],
      "tools": ["*"]
    },
    "postgres": {
      "type": "local",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://localhost/mydb"],
      "tools": ["*"]
    },
    "sequential-thinking": {
      "type": "local",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "tools": ["*"]
    }
  }
}
```

### Project-Specific Configuration

Create `.copilot/mcp-config.json` in your project root:

```json
{
  "mcpServers": {
    "project-specific": {
      "type": "local",
      "command": "node",
      "args": ["./tools/mcp-server.js"],
      "tools": ["*"]
    }
  }
}
```

### Runtime Configuration

Pass MCP configuration at runtime:

```bash
# Inline JSON
copilot --additional-mcp-config '{"mcpServers": {"my-tool": {...}}}'

# From file
copilot --additional-mcp-config @/path/to/config.json

# Multiple configurations (later values override earlier ones)
copilot --additional-mcp-config @base.json --additional-mcp-config @overrides.json
```

---

## Shell Completions

### Installing Completions

For Bash, add to `~/.bashrc`:

```bash
# Basic command completion
complete -C copilot copilot
```

For Zsh, add to `~/.zshrc`:

```zsh
# Enable completion system
autoload -Uz compinit && compinit

# Basic command completion
compdef _gnu_generic copilot
```

For PowerShell, add to your `$PROFILE`:

```powershell
# Basic command completion
Register-ArgumentCompleter -Native -CommandName copilot -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    copilot --help | Select-String "^\s*--" | ForEach-Object {
        $_.Line.Trim() -split '\s+' | Select-Object -First 1
    } | Where-Object { $_ -like "$wordToComplete*" }
}
```

---

## Git Hooks Integration

### Pre-commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash

# Use Copilot to review staged changes
echo "Running Copilot pre-commit review..."
git diff --cached | copilot -p "Review these changes for potential issues, security vulnerabilities, and code quality. Be concise."

# Exit code doesn't block commit, just provides feedback
exit 0
```

Make it executable:

```bash
chmod +x .git/hooks/pre-commit
```

### Commit Message Hook

Create `.git/hooks/prepare-commit-msg`:

```bash
#!/bin/bash

COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2

# Only generate message for regular commits (not amend, merge, etc.)
if [ -z "$COMMIT_SOURCE" ]; then
    # Get staged changes
    DIFF=$(git diff --cached)
    
    # Generate commit message using Copilot
    if [ -n "$DIFF" ]; then
        MESSAGE=$(echo "$DIFF" | copilot -p "Generate a concise, conventional commit message for these changes. Use format: type(scope): description")
        
        # Prepend generated message to commit file
        echo "$MESSAGE" > "$COMMIT_MSG_FILE.tmp"
        echo "" >> "$COMMIT_MSG_FILE.tmp"
        cat "$COMMIT_MSG_FILE" >> "$COMMIT_MSG_FILE.tmp"
        mv "$COMMIT_MSG_FILE.tmp" "$COMMIT_MSG_FILE"
    fi
fi
```

Make it executable:

```bash
chmod +x .git/hooks/prepare-commit-msg
```

---

## CI/CD Integration

### GitHub Actions

Create `.github/workflows/copilot-review.yml`:

```yaml
name: Copilot Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '22'

      - name: Install Copilot CLI
        run: npm install -g @github/copilot

      - name: Review Changes
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          # Get PR diff
          git diff origin/${{ github.base_ref }}...HEAD > pr_diff.txt
          
          # Review with Copilot
          copilot -p "Review this PR for code quality, security issues, and best practices. Provide specific, actionable feedback." < pr_diff.txt > review.txt
          
          # Post as comment (requires gh CLI)
          gh pr comment ${{ github.event.pull_request.number }} --body-file review.txt
```

### GitLab CI

Create `.gitlab-ci.yml`:

```yaml
copilot-review:
  stage: review
  image: node:22
  before_script:
    - npm install -g @github/copilot
  script:
    - git diff $CI_MERGE_REQUEST_TARGET_BRANCH_SHA...$CI_COMMIT_SHA > mr_diff.txt
    - copilot -p "Review these changes for quality and security issues" < mr_diff.txt > review.txt
    - cat review.txt
  only:
    - merge_requests
  variables:
    GITHUB_TOKEN: $COPILOT_TOKEN
```

### Jenkins Pipeline

Create `Jenkinsfile`:

```groovy
pipeline {
    agent any
    
    environment {
        GITHUB_TOKEN = credentials('github-token')
    }
    
    stages {
        stage('Setup') {
            steps {
                sh 'npm install -g @github/copilot'
            }
        }
        
        stage('Code Review') {
            steps {
                sh '''
                    git diff ${GIT_PREVIOUS_COMMIT}..${GIT_COMMIT} > changes.txt
                    copilot -p "Review these changes for issues" < changes.txt > review.txt
                    cat review.txt
                '''
            }
        }
    }
}
```

---

## Custom Workflows

### Code Review Automation

Create `scripts/copilot-review.sh`:

```bash
#!/bin/bash

# Review specific files or directories
TARGET=${1:-.}

echo "Reviewing: $TARGET"

# For files
if [ -f "$TARGET" ]; then
    cat "$TARGET" | copilot -p "Review this code for quality, security, and best practices. Be specific and actionable."
    exit 0
fi

# For directories
if [ -d "$TARGET" ]; then
    find "$TARGET" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" \) | while read file; do
        echo "=== Reviewing: $file ==="
        cat "$file" | copilot -p "Quick security and quality review. Flag only critical issues."
        echo ""
    done
fi
```

### Documentation Generation

Create `scripts/generate-docs.sh`:

```bash
#!/bin/bash

# Generate documentation for source files
SOURCE_DIR=${1:-src}
DOCS_DIR=${2:-docs}

mkdir -p "$DOCS_DIR"

find "$SOURCE_DIR" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" \) | while read file; do
    filename=$(basename "$file")
    doc_file="$DOCS_DIR/${filename%.*}.md"
    
    echo "Generating docs for: $file"
    cat "$file" | copilot -p "Generate comprehensive documentation for this code. Include function descriptions, parameters, return values, and usage examples in Markdown format." > "$doc_file"
done

echo "Documentation generated in: $DOCS_DIR"
```

### Test Generation

Create `scripts/generate-tests.sh`:

```bash
#!/bin/bash

# Generate tests for source files
SOURCE_FILE=$1

if [ -z "$SOURCE_FILE" ]; then
    echo "Usage: $0 <source-file>"
    exit 1
fi

# Determine test file path
case "$SOURCE_FILE" in
    *.js)   TEST_FILE="${SOURCE_FILE%.js}.test.js" ;;
    *.ts)   TEST_FILE="${SOURCE_FILE%.ts}.test.ts" ;;
    *.py)   TEST_FILE="${SOURCE_FILE%.py}_test.py" ;;
    *)      echo "Unsupported file type"; exit 1 ;;
esac

echo "Generating tests for: $SOURCE_FILE"
echo "Output: $TEST_FILE"

cat "$SOURCE_FILE" | copilot -p "Generate comprehensive unit tests for this code. Include edge cases, error handling, and integration scenarios. Use appropriate testing framework for the language." > "$TEST_FILE"

echo "Tests generated: $TEST_FILE"
```

### Refactoring Assistant

Create `scripts/refactor-code.sh`:

```bash
#!/bin/bash

FILE=$1
GOAL=${2:-"improve code quality and maintainability"}

if [ -z "$FILE" ]; then
    echo "Usage: $0 <file> [goal]"
    exit 1
fi

echo "Refactoring: $FILE"
echo "Goal: $GOAL"

# Backup original
cp "$FILE" "$FILE.backup"

# Generate refactored version
cat "$FILE" | copilot -p "Refactor this code to $GOAL. Maintain functionality but improve structure, readability, and performance. Provide only the refactored code." > "$FILE.new"

# Show diff
echo "=== Changes ==="
diff -u "$FILE" "$FILE.new"

echo ""
echo "Review the changes above."
echo "To apply: mv $FILE.new $FILE"
echo "To revert: mv $FILE.backup $FILE"
```

---

## Environment Variables

Copilot CLI recognizes these environment variables:

```bash
# Authentication
export GITHUB_TOKEN="your-token-here"
export GH_TOKEN="your-token-here"  # Alternative

# Configuration
export COPILOT_WORKSPACE="/path/to/workspace"
export COPILOT_MODEL="claude-sonnet-4.5"  # Default model

# MCP Configuration
export COPILOT_MCP_CONFIG="/path/to/mcp-config.json"

# Behavior
export COPILOT_STREAM="on"  # Enable streaming
export COPILOT_DEBUG="true"  # Enable debug logging
```

---

## Troubleshooting

### MCP Server Issues

If MCP tools are not visible:

1. Verify MCP configuration file location: `~/.copilot/mcp-config.json`
2. Check server executables are in PATH: `which npx`, `which uvx`
3. Test server startup manually: `npx -y @modelcontextprotocol/server-filesystem`
4. Check server processes: `ps aux | grep mcp`
5. Enable debug logging: `COPILOT_DEBUG=true copilot`

### Authentication Issues

If authentication fails:

1. Verify token is set: `echo $GITHUB_TOKEN`
2. Check token permissions at: https://github.com/settings/tokens
3. Ensure "Copilot Requests" permission is enabled
4. Try re-authenticating: `/login` command in Copilot CLI

### Performance Issues

If Copilot is slow:

1. Reduce context size by limiting file access
2. Disable unnecessary MCP servers
3. Use `--stream off` if streaming causes issues
4. Check network connectivity
5. Verify system resources (RAM, CPU)

---

## Best Practices

1. **Use Project-Specific Configuration**: Keep MCP configs in project root
2. **Secure Tokens**: Never commit tokens to version control
3. **Limit Tool Access**: Only enable MCP tools you need (`tools: ["specific-tool"]`)
4. **Version Control Hooks**: Make hooks non-blocking (always exit 0)
5. **CI/CD Integration**: Use read-only operations in CI pipelines
6. **Regular Updates**: Keep Copilot CLI updated: `npm update -g @github/copilot`

---

## Additional Resources

- [Official Documentation](https://docs.github.com/copilot/concepts/agents/about-copilot-cli)
- [MCP Specification](https://modelcontextprotocol.io/)
- [GitHub CLI](https://cli.github.com/)
- [Community Discussions](https://github.com/github/copilot-cli/discussions)

---

For issues or feature requests, visit: https://github.com/github/copilot-cli/issues
