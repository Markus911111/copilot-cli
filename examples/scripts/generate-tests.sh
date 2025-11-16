#!/bin/bash
# Generate unit tests for source files using Copilot
# Usage: ./generate-tests.sh <source-file>

set -e

SOURCE_FILE=$1

if [ -z "$SOURCE_FILE" ]; then
    echo "Usage: $0 <source-file>"
    echo ""
    echo "Examples:"
    echo "  $0 src/utils.js"
    echo "  $0 lib/parser.py"
    echo "  $0 pkg/handler.go"
    exit 1
fi

if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: File '$SOURCE_FILE' does not exist"
    exit 1
fi

# Determine test file path based on language
case "$SOURCE_FILE" in
    *.js)   
        TEST_FILE="${SOURCE_FILE%.js}.test.js"
        FRAMEWORK="Jest"
        ;;
    *.ts)   
        TEST_FILE="${SOURCE_FILE%.ts}.test.ts"
        FRAMEWORK="Jest with TypeScript"
        ;;
    *.jsx)  
        TEST_FILE="${SOURCE_FILE%.jsx}.test.jsx"
        FRAMEWORK="Jest with React Testing Library"
        ;;
    *.tsx)  
        TEST_FILE="${SOURCE_FILE%.tsx}.test.tsx"
        FRAMEWORK="Jest with React Testing Library and TypeScript"
        ;;
    *.py)   
        TEST_FILE="${SOURCE_FILE%.py}_test.py"
        FRAMEWORK="pytest"
        ;;
    *.go)   
        TEST_FILE="${SOURCE_FILE%.go}_test.go"
        FRAMEWORK="Go testing package"
        ;;
    *.rs)   
        # Rust tests usually in same file, but can be separate
        TEST_FILE="${SOURCE_FILE%.rs}_test.rs"
        FRAMEWORK="Rust built-in testing"
        ;;
    *.java) 
        # Java test in test directory
        TEST_FILE=$(echo "$SOURCE_FILE" | sed 's/src\/main/src\/test/' | sed 's/\.java$/Test.java/')
        FRAMEWORK="JUnit 5"
        ;;
    *)      
        echo "Error: Unsupported file type"
        echo "Supported: .js, .ts, .jsx, .tsx, .py, .go, .rs, .java"
        exit 1
        ;;
esac

echo "🧪 Generating tests for: $SOURCE_FILE"
echo "📝 Output file: $TEST_FILE"
echo "🔧 Framework: $FRAMEWORK"
echo ""

# Check if test file already exists
if [ -f "$TEST_FILE" ]; then
    read -p "Test file already exists. Overwrite? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cancelled"
        exit 1
    fi
fi

# Generate tests using Copilot
cat "$SOURCE_FILE" | copilot -p "Generate comprehensive unit tests for this code using $FRAMEWORK.

Requirements:
1. Test all public functions/methods
2. Include edge cases and error handling
3. Test boundary conditions
4. Mock external dependencies appropriately
5. Follow testing best practices for the language
6. Include descriptive test names
7. Add comments explaining complex test scenarios

Provide ONLY the test code, no explanations." > "$TEST_FILE"

echo ""
echo "✅ Tests generated: $TEST_FILE"
echo ""
echo "Next steps:"
echo "  1. Review the generated tests"
echo "  2. Run tests: [your test command]"
echo "  3. Adjust as needed"
