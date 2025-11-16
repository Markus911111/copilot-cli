#!/bin/bash
# Copilot Code Review Script
# Usage: ./copilot-review.sh [file-or-directory]

set -e

TARGET=${1:-.}

if [ ! -e "$TARGET" ]; then
    echo "Error: '$TARGET' does not exist"
    exit 1
fi

echo "🔍 Starting Copilot review of: $TARGET"
echo ""

# Function to review a single file
review_file() {
    local file=$1
    echo "📄 Reviewing: $file"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    cat "$file" | copilot -p "Review this code for:
    1. Security vulnerabilities
    2. Code quality issues
    3. Performance problems
    4. Best practices violations
    
    Be specific and provide actionable feedback with line numbers when possible."
    
    echo ""
    echo ""
}

# Review single file
if [ -f "$TARGET" ]; then
    review_file "$TARGET"
    exit 0
fi

# Review directory
if [ -d "$TARGET" ]; then
    # Find all code files
    find "$TARGET" -type f \( \
        -name "*.js" -o \
        -name "*.ts" -o \
        -name "*.jsx" -o \
        -name "*.tsx" -o \
        -name "*.py" -o \
        -name "*.go" -o \
        -name "*.rs" -o \
        -name "*.java" -o \
        -name "*.cpp" -o \
        -name "*.c" -o \
        -name "*.h" \
    \) | while read file; do
        review_file "$file"
    done
    
    echo "✅ Review complete!"
    exit 0
fi

echo "Error: '$TARGET' is neither a file nor directory"
exit 1
