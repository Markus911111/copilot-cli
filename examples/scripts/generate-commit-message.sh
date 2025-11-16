#!/bin/bash
# Generate conventional commit messages using Copilot
# Usage: ./generate-commit-message.sh

set -e

# Check if there are staged changes
if ! git diff --cached --quiet; then
    echo "📝 Generating commit message for staged changes..."
    echo ""
    
    # Get the diff of staged changes
    DIFF=$(git diff --cached)
    
    # Generate commit message using Copilot
    MESSAGE=$(echo "$DIFF" | copilot -p "Generate a conventional commit message for these changes.
    
    Format: <type>(<scope>): <description>
    
    Types: feat, fix, docs, style, refactor, test, chore
    
    Rules:
    - Use lowercase for type and description
    - Keep description under 72 characters
    - Be specific but concise
    - Focus on WHAT changed and WHY
    
    Provide only the commit message, nothing else.")
    
    echo "Generated commit message:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$MESSAGE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    read -p "Use this commit message? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git commit -m "$MESSAGE"
        echo "✅ Changes committed!"
    else
        echo "❌ Commit cancelled"
        exit 1
    fi
else
    echo "No staged changes found. Stage changes with: git add <files>"
    exit 1
fi
