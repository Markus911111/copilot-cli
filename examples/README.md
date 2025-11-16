# GitHub Copilot CLI Examples

This directory contains practical examples and templates for integrating GitHub Copilot CLI into your development workflow.

## Directory Structure

```
examples/
├── mcp-configs/          # MCP server configuration examples
├── scripts/              # Shell scripts for automation
├── workflows/            # CI/CD workflow examples
└── README.md            # This file
```

## MCP Configurations

Located in `mcp-configs/`:

- **`basic-mcp-config.json`** - Basic setup with filesystem, GitHub, and Git MCP servers
- **`advanced-mcp-config.json`** - Advanced setup with database, search, and communication integrations
- **`development-mcp-config.json`** - Development-focused configuration with limited GitHub tools

### Usage

Copy a configuration file to your home directory:

```bash
# For system-wide configuration
cp examples/mcp-configs/basic-mcp-config.json ~/.copilot/mcp-config.json

# For project-specific configuration
cp examples/mcp-configs/development-mcp-config.json .copilot/mcp-config.json
```

Don't forget to set required environment variables:

```bash
export GITHUB_TOKEN="your-token"
export WORKSPACE="$(pwd)"
```

## Scripts

Located in `scripts/`:

### Code Review Script

**`copilot-review.sh`** - Review code files or directories for issues

```bash
# Make executable
chmod +x examples/scripts/copilot-review.sh

# Review a single file
./examples/scripts/copilot-review.sh src/utils.js

# Review entire directory
./examples/scripts/copilot-review.sh src/
```

### Commit Message Generator

**`generate-commit-message.sh`** - Generate conventional commit messages

```bash
# Make executable
chmod +x examples/scripts/generate-commit-message.sh

# Stage your changes
git add .

# Generate and commit
./examples/scripts/generate-commit-message.sh
```

### Test Generator

**`generate-tests.sh`** - Generate unit tests for source files

```bash
# Make executable
chmod +x examples/scripts/generate-tests.sh

# Generate tests
./examples/scripts/generate-tests.sh src/utils.js
# Creates: src/utils.test.js

./examples/scripts/generate-tests.sh lib/parser.py
# Creates: lib/parser_test.py
```

Supports:
- JavaScript (`.js`) → Jest
- TypeScript (`.ts`) → Jest
- React (`.jsx`, `.tsx`) → React Testing Library
- Python (`.py`) → pytest
- Go (`.go`) → Go testing
- Rust (`.rs`) → Rust testing
- Java (`.java`) → JUnit 5

### Documentation Generator

**`generate-docs.sh`** - Generate API documentation

```bash
# Make executable
chmod +x examples/scripts/generate-docs.sh

# Generate docs for single file
./examples/scripts/generate-docs.sh src/utils.js

# Generate docs for directory
./examples/scripts/generate-docs.sh src/ docs/api
```

## Workflows

Located in `workflows/`:

### GitHub Actions

**`github-actions-review.yml`** - Automated PR reviews

Copy to your repository:

```bash
cp examples/workflows/github-actions-review.yml .github/workflows/
```

Requires:
- GitHub token with Copilot access (automatically provided)
- PR permissions (configured in workflow)

### GitLab CI

**`gitlab-ci-review.yml`** - Automated MR reviews

Copy to your repository:

```bash
cp examples/workflows/gitlab-ci-review.yml .gitlab-ci.yml
```

Or merge with existing `.gitlab-ci.yml`:

```yaml
include:
  - local: examples/workflows/gitlab-ci-review.yml
```

Requires:
- `COPILOT_GITHUB_TOKEN` variable (with Copilot access)
- `GITLAB_TOKEN` variable (optional, for posting comments)

## Quick Start

1. **Install Copilot CLI**:
   ```bash
   npm install -g @github/copilot
   ```

2. **Set up authentication**:
   ```bash
   export GITHUB_TOKEN="your-personal-access-token"
   ```

3. **Copy and customize MCP config**:
   ```bash
   mkdir -p ~/.copilot
   cp examples/mcp-configs/basic-mcp-config.json ~/.copilot/mcp-config.json
   ```

4. **Make scripts executable**:
   ```bash
   chmod +x examples/scripts/*.sh
   ```

5. **Test it out**:
   ```bash
   # Review a file
   ./examples/scripts/copilot-review.sh README.md
   ```

## Environment Variables

Scripts and workflows use these environment variables:

| Variable | Description | Required |
|----------|-------------|----------|
| `GITHUB_TOKEN` | GitHub personal access token with Copilot access | Yes |
| `WORKSPACE` | Current workspace/project directory | No (defaults to pwd) |
| `COPILOT_MODEL` | Model to use (e.g., claude-sonnet-4.5) | No |
| `PGUSER` | PostgreSQL username (for postgres MCP) | If using postgres |
| `PGPASSWORD` | PostgreSQL password (for postgres MCP) | If using postgres |
| `BRAVE_API_KEY` | Brave Search API key (for search MCP) | If using Brave Search |
| `SLACK_BOT_TOKEN` | Slack bot token (for Slack MCP) | If using Slack |
| `SLACK_TEAM_ID` | Slack team ID (for Slack MCP) | If using Slack |

## Best Practices

1. **Start Simple**: Begin with `basic-mcp-config.json` and add servers as needed
2. **Secure Tokens**: Never commit tokens to version control; use environment variables
3. **Test Scripts**: Review generated code/tests/docs before using in production
4. **Customize Prompts**: Adjust prompts in scripts to match your team's standards
5. **CI/CD Integration**: Make CI checks advisory, not blocking, initially

## Troubleshooting

### MCP servers not connecting

```bash
# Check if executables are in PATH
which npx

# Test server startup manually
npx -y @modelcontextprotocol/server-filesystem ~/projects

# Check Copilot logs
COPILOT_DEBUG=true copilot
```

### Scripts not working

```bash
# Ensure scripts are executable
chmod +x examples/scripts/*.sh

# Check Copilot is installed
copilot --version

# Verify authentication
echo $GITHUB_TOKEN
```

### Workflow failures

- Check GitHub token has Copilot access
- Verify token permissions in repository secrets
- Review workflow logs for specific errors

## Contributing

Have a useful script or configuration? Contributions are welcome!

1. Add your example with clear comments
2. Update this README with usage instructions
3. Test thoroughly before submitting

## Additional Resources

- [Integration Guide](../INTEGRATION.md) - Comprehensive integration documentation
- [Official Docs](https://docs.github.com/copilot/concepts/agents/about-copilot-cli)
- [MCP Specification](https://modelcontextprotocol.io/)

## Support

For issues or questions:
- [GitHub Copilot CLI Issues](https://github.com/github/copilot-cli/issues)
- [Community Discussions](https://github.com/github/copilot-cli/discussions)
