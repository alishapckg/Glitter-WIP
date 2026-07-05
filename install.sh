#!/bin/bash
# install.sh - Install y2k-zones command globally
set -e

echo "🎀 Installing Y2K Zones..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${SCRIPT_DIR}/bin"
mkdir -p "${BIN_DIR}"

# Copy script
cp "${SCRIPT_DIR}/bin/y2k-zones" "${BIN_DIR}/y2k-zones" 2>/dev/null || true
chmod +x "${BIN_DIR}/y2k-zones"

# Create symlink in /usr/local/bin
INSTALL_PATH="/usr/local/bin/y2k-zones"

if [ -w "/usr/local/bin" ]; then
    ln -sf "${BIN_DIR}/y2k-zones" "${INSTALL_PATH}"
else
    echo "Need sudo for /usr/local/bin"
    sudo ln -sf "${BIN_DIR}/y2k-zones" "${INSTALL_PATH}"
fi

echo ""
echo "✓ Installed to ${INSTALL_PATH}"
echo ""
echo "Test with: y2k-zones --help"
echo ""
echo "🎉 Done!"
