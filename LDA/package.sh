#!/bin/bash

# ============================================================================
# Package MALLET Replication Scripts for Distribution
# ============================================================================
# Purpose: Create a clean distribution zip file for server deployment
# Usage: ./package.sh
# Output: mallet_replication.zip
# ============================================================================

set -e  # Exit on error

PACKAGE_NAME="mallet_replication"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ZIP_FILE="${PACKAGE_NAME}.zip"
BACKUP_ZIP="${PACKAGE_NAME}_${TIMESTAMP}.zip"

echo "================================================================================"
echo "MALLET Replication Scripts - Package Builder"
echo "================================================================================"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Working directory: $SCRIPT_DIR"
echo ""

# Clean up any previous builds
if [[ -f "$ZIP_FILE" ]]; then
    echo "Backing up existing zip..."
    mv "$ZIP_FILE" "$BACKUP_ZIP"
    echo "  ✓ Backed up to: $BACKUP_ZIP"
fi

# Create temporary packaging directory
TEMP_DIR=$(mktemp -d)
PACKAGE_DIR="$TEMP_DIR/$PACKAGE_NAME"
mkdir -p "$PACKAGE_DIR"

echo ""
echo "Copying files to package directory..."

# Core scripts
echo "  → Core scripts"
cp mallet_LDA.sh "$PACKAGE_DIR/"
cp mallet_inference.sh "$PACKAGE_DIR/"

# Configuration
echo "  → Configuration files"
cp config.template.sh "$PACKAGE_DIR/"
cp default_stoplist.txt "$PACKAGE_DIR/"
cp .gitignore "$PACKAGE_DIR/"

# Documentation
echo "  → Documentation"
cp README.md "$PACKAGE_DIR/"
cp DEPLOY.md "$PACKAGE_DIR/"
cp QUICKSTART.md "$PACKAGE_DIR/"

# Make scripts executable
echo ""
echo "Setting permissions..."
chmod +x "$PACKAGE_DIR/mallet_LDA.sh"
chmod +x "$PACKAGE_DIR/mallet_inference.sh"

# Create manifest
echo ""
echo "Creating manifest..."
cat > "$PACKAGE_DIR/MANIFEST.txt" << EOF
MALLET Topic Modeling - Replication Package
============================================

Package created: $(date)
Package version: 2.0

Contents:
---------

Core Scripts:
  - mallet_LDA.sh       Main topic modeling script
  - mallet_inference.sh        Inference on new documents

Configuration:
  - config.template.sh         Configuration template
  - default_stoplist.txt       Default stopword list (replace with yours)
  - .gitignore                 Git ignore rules

Documentation:
  - README.md                  Complete documentation
  - DEPLOY.md                  Server deployment guide
  - QUICKSTART.md              Quick reference
  - MANIFEST.txt               This file

Setup Instructions:
-------------------

1. Quick Start:
   See QUICKSTART.md for 30-second setup

2. Detailed Guide:
   See DEPLOY.md for step-by-step instructions

3. Full Documentation:
   See README.md for complete information

Model Parameters (Fixed):
-------------------------
  - Topics: 60
  - Random seed: 1
  - Optimization interval: 500

These are hardcoded for exact reproducibility.

Requirements:
-------------
  - MALLET installed and in PATH
  - Java 1.8 or higher
  - Bash 4.0+
  - SLURM (optional, for HPC)

Support:
--------
  - Run scripts with --help for usage
  - Review README.md for troubleshooting

License:
--------
[To be determined]

EOF

# Count files
FILE_COUNT=$(find "$PACKAGE_DIR" -type f | wc -l | tr -d ' ')
TOTAL_SIZE=$(du -sh "$PACKAGE_DIR" | cut -f1)

echo "  ✓ Manifest created"
echo ""
echo "Package contents:"
echo "  Files: $FILE_COUNT"
echo "  Size: $TOTAL_SIZE"
echo ""

# Create zip file
echo "Creating zip file..."
cd "$TEMP_DIR"
zip -r "$SCRIPT_DIR/$ZIP_FILE" "$PACKAGE_NAME" > /dev/null 2>&1

cd "$SCRIPT_DIR"

# Cleanup
rm -rf "$TEMP_DIR"

# Verify zip
if [[ -f "$ZIP_FILE" ]]; then
    ZIP_SIZE=$(du -h "$ZIP_FILE" | cut -f1)
    echo "  ✓ Created: $ZIP_FILE ($ZIP_SIZE)"
else
    echo "  ✗ ERROR: Failed to create zip file"
    exit 1
fi

echo ""
echo "================================================================================"
echo "Package Summary"
echo "================================================================================"
echo ""
echo "Package file: $ZIP_FILE"
echo "Package size: $ZIP_SIZE"
echo "Files included: $FILE_COUNT"
echo ""
echo "Contents:"
zip -sf "$ZIP_FILE" | head -20
echo "  ... (see MANIFEST.txt in zip for complete list)"
echo ""
echo "================================================================================"
echo "Next Steps"
echo "================================================================================"
echo ""
echo "1. Transfer to server:"
echo "   scp $ZIP_FILE user@server:~"
echo ""
echo "2. On server:"
echo "   unzip $ZIP_FILE"
echo "   cd $PACKAGE_NAME"
echo "   cat QUICKSTART.md"
echo ""
echo "3. Configure and run:"
echo "   cp config.template.sh config.sh"
echo "   vim config.sh  # Edit paths"
echo "   sbatch mallet_LDA.sh"
echo ""
echo "For detailed instructions, see DEPLOY.md in the package"
echo ""
echo "================================================================================"
echo "✓ Package ready for deployment!"
echo "================================================================================"
