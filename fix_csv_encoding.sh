#!/bin/bash

# Script to fix CSV encoding issues
# Removes BOM and ensures UTF-8 encoding

CSV_FILE="/Users/vladburkov/Downloads/RetailSaleAnalysisData.csv"
OUTPUT_FILE="/Users/vladburkov/Downloads/RetailSaleAnalysisData_fixed.csv"

echo "🔧 Fixing CSV encoding..."

# Check if file exists
if [ ! -f "$CSV_FILE" ]; then
    echo "❌ Error: File not found at $CSV_FILE"
    echo "Please update CSV_FILE path in the script"
    exit 1
fi

# Remove BOM and convert to UTF-8
if command -v python3 &> /dev/null; then
    echo "Using Python to fix encoding..."
    python3 << EOF
import codecs

# Read file
with open('$CSV_FILE', 'rb') as f:
    content = f.read()

# Remove BOM if present
if content.startswith(codecs.BOM_UTF8):
    content = content[3:]
    print("✅ Removed UTF-8 BOM")

# Write back as UTF-8
with open('$OUTPUT_FILE', 'wb') as f:
    f.write(content)

print(f"✅ Fixed file saved to: $OUTPUT_FILE")
EOF
elif command -v sed &> /dev/null; then
    echo "Using sed to remove BOM..."
    sed -i '' '1s/^\xEF\xBB\xBF//' "$CSV_FILE"
    echo "✅ BOM removed from original file"
else
    echo "❌ Error: Need Python3 or sed to fix encoding"
    exit 1
fi

echo ""
echo "✅ Done! Now try importing: $OUTPUT_FILE"
echo "Or use the original file if BOM was removed"
