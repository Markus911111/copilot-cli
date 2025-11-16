#!/bin/bash
# Generate documentation for source files using Copilot
# Usage: ./generate-docs.sh <source-file-or-directory> [output-directory]

set -e

SOURCE=$1
DOCS_DIR=${2:-docs}

if [ -z "$SOURCE" ]; then
    echo "Usage: $0 <source-file-or-directory> [output-directory]"
    echo ""
    echo "Examples:"
    echo "  $0 src/utils.js"
    echo "  $0 src/ docs/api"
    exit 1
fi

if [ ! -e "$SOURCE" ]; then
    echo "Error: '$SOURCE' does not exist"
    exit 1
fi

mkdir -p "$DOCS_DIR"

# Function to generate docs for a single file
generate_docs() {
    local file=$1
    local filename=$(basename "$file")
    local doc_file="$DOCS_DIR/${filename%.*}.md"
    
    echo "📄 Generating docs for: $file"
    
    cat "$file" | copilot -p "Generate comprehensive API documentation for this code in Markdown format.

Include:
1. File overview and purpose
2. All public functions/methods/classes with:
   - Description
   - Parameters (name, type, description)
   - Return values (type, description)
   - Exceptions/Errors
   - Usage examples
3. Code examples showing common use cases
4. Any important notes or warnings

Format in clean Markdown suitable for documentation sites." > "$doc_file"
    
    echo "  ✅ Created: $doc_file"
}

echo "📚 Generating documentation..."
echo "📂 Output directory: $DOCS_DIR"
echo ""

# Generate for single file
if [ -f "$SOURCE" ]; then
    generate_docs "$SOURCE"
    echo ""
    echo "✅ Documentation generated!"
    exit 0
fi

# Generate for directory
if [ -d "$SOURCE" ]; then
    find "$SOURCE" -type f \( \
        -name "*.js" -o \
        -name "*.ts" -o \
        -name "*.jsx" -o \
        -name "*.tsx" -o \
        -name "*.py" -o \
        -name "*.go" -o \
        -name "*.rs" -o \
        -name "*.java" \
    \) | while read file; do
        generate_docs "$file"
    done
    
    # Generate index
    echo "📑 Generating index..."
    INDEX_FILE="$DOCS_DIR/README.md"
    
    {
        echo "# API Documentation"
        echo ""
        echo "Generated documentation for source files in \`$SOURCE\`"
        echo ""
        echo "## Files"
        echo ""
        
        find "$DOCS_DIR" -name "*.md" ! -name "README.md" | sort | while read doc; do
            filename=$(basename "$doc" .md)
            echo "- [$filename](./$filename.md)"
        done
    } > "$INDEX_FILE"
    
    echo "  ✅ Created: $INDEX_FILE"
    echo ""
    echo "✅ Documentation generated in: $DOCS_DIR"
    exit 0
fi

echo "Error: '$SOURCE' is neither a file nor directory"
exit 1
