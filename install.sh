#!/bin/bash
# ============================================================================
# Y2K Zones - Smart Auto-Installer
# Automatically installs: Python dependencies + ffmpeg + command
# ============================================================================

set -e

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}🎀 Y2K Zones - Automatic Installer${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# ============================================================================
# STEP 1: Check Python 3
# ============================================================================

echo -e "${YELLOW}[1/5] Checking Python 3...${NC}"

if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    echo -e "  ${GREEN}✓${NC} Python found: $PYTHON_VERSION"
else
    echo -e "  ${RED}✗${NC} Python 3 not found!"
    echo ""
    echo -e "  ${YELLOW}Installing Python 3...${NC}"
    
    # Try Homebrew
    if command -v brew &> /dev/null; then
        brew install python@3.11
    else
        echo -e "  ${RED}Error: Please install Python 3 first:${NC}"
        echo "  → Download from: https://www.python.org/downloads/"
        echo "  → Or install via: brew install python"
        exit 1
    fi
fi

PYTHON_CMD="python3"

# ============================================================================
# STEP 2: Install Python Dependencies (opencv + numpy)
# ============================================================================

echo ""
echo -e "${YELLOW}[2/5] Installing Python dependencies...${NC}"

# Check if opencv is installed AND has CSRT tracker support (contrib
# modules). "Track motion" needs opencv-contrib-python; plain
# opencv-python/opencv-python-headless does not include the tracker.
HAS_CSRT=$($PYTHON_CMD -c "
import cv2
ok = hasattr(cv2, 'TrackerCSRT_create') or (hasattr(cv2, 'legacy') and hasattr(cv2.legacy, 'TrackerCSRT_create'))
print('yes' if ok else 'no')
" 2>/dev/null || echo "no")

if $PYTHON_CMD -c "import cv2" 2> /dev/null && [ "$HAS_CSRT" = "yes" ]; then
    CV_VERSION=$($PYTHON_CMD -c "import cv2; print(cv2.__version__)")
    echo -e "  ${GREEN}✓${NC} OpenCV already installed with tracking support: $CV_VERSION"
else
    if $PYTHON_CMD -c "import cv2" 2> /dev/null; then
        echo -e "  ${YELLOW}OpenCV found but missing CSRT tracker support.${NC}"
        echo -e "  ${YELLOW}Replacing with opencv-contrib-python...${NC}"
        $PYTHON_CMD -m pip uninstall -y opencv-python opencv-python-headless opencv-contrib-python-headless 2>/dev/null || true
    else
        echo -e "  ${YELLOW}Installing OpenCV (opencv-contrib-python)...${NC}"
    fi
    $PYTHON_CMD -m pip install --user opencv-contrib-python numpy
    echo -e "  ${GREEN}✓${NC} OpenCV (with tracking support) installed!"
fi

# Check numpy
if $PYTHON_CMD -c "import numpy" 2> /dev/null; then
    NP_VERSION=$($PYTHON_CMD -c "import numpy; print(numpy.__version__)")
    echo -e "  ${GREEN}✓${NC} NumPy already installed: $NP_VERSION"
else
    echo -e "  ${YELLOW}Installing NumPy...${NC}"
    $PYTHON_CMD -m pip install --user numpy
    echo -e "  ${GREEN}✓${NC} NumPy installed!"
fi

# ============================================================================
# STEP 3: Install ffmpeg (for audio support)
# ============================================================================

echo ""
echo -e "${YELLOW}[3/5] Checking ffmpeg (for audio support)...${NC}"

if command -v ffmpeg &> /dev/null; then
    FFMPEG_VERSION=$(ffmpeg -version 2>&1 | head -n1 | awk '{print $3}')
    echo -e "  ${GREEN}✓${NC} ffmpeg already installed: $FFMPEG_VERSION"
else
    echo -e "  ${YELLOW}ffmpeg not found. Installing...${NC}"
    
    if command -v brew &> /dev/null; then
        echo -e "  Installing via Homebrew..."
        brew install ffmpeg
        echo -e "  ${GREEN}✓${NC} ffmpeg installed!"
    else
        echo -e "  ${YELLOW}⚠ Homebrew not found.${NC}"
        echo -e "  ${YELLOW}  Audio features will be disabled.${NC}"
        echo -e "  ${YELLOW}  To enable audio later: brew install ffmpeg${NC}"
    fi
fi

# ============================================================================
# STEP 4: Install y2k-zones Command
# ============================================================================

echo ""
echo -e "${YELLOW}[4/5] Installing y2k-zones command...${NC}"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${SCRIPT_DIR}/bin"

# Ensure bin directory exists
mkdir -p "${BIN_DIR}"

# Copy script
if [ -f "${BIN_DIR}/y2k-zones" ]; then
    cp "${BIN_DIR}/y2k-zones" "${BIN_DIR}/y2k-zones" 2>/dev/null || true
fi

chmod +x "${BIN_DIR}/y2k-zones"

# Create symlink in /usr/local/bin
INSTALL_PATH="/usr/local/bin/y2k-zones"

if [ -w "/usr/local/bin" ]; then
    ln -sf "${BIN_DIR}/y2k-zones" "${INSTALL_PATH}" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Installed to: ${INSTALL_PATH}"
else
    echo -e "  ${YELLOW}Need sudo access for /usr/local/bin${NC}"
    sudo ln -sf "${BIN_DIR}/y2k-zones" "${INSTALL_PATH}"
    echo -e "  ${GREEN}✓${NC} Installed to: ${INSTALL_PATH}"
fi

# ============================================================================
# STEP 5: Verify Installation
# ============================================================================

echo ""
echo -e "${YELLOW}[5/5] Verifying installation...${NC}"

# Small delay to let system recognize new command
sleep 1

if command -v y2k-zones &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} y2k-zones command available!"
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                      ║${NC}"
    echo -e "${GREEN}║   ✨ INSTALLATION COMPLETE! ✨       ║${NC}"
    echo -e "${GREEN}║                                      ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  Usage: ${BLUE}y2k-zones <video_file>${NC}"
    echo -e "  Example: ${BLUE}y2k-zones my_video.mov${NC}"
    echo ""
    echo -e "  To update later: ${YELLOW}cd /path/to/Glitter && ./install.sh${NC}"
    echo ""
else
    echo -e "  ${RED}✗${NC} Installation may have failed"
    echo ""
    echo -e "  Manual setup:"
    echo -e "    export PATH=\"${BIN_DIR}:\$PATH\""
    echo -e "    y2k-zones --help"
fi

# ============================================================================
# Optional: Add to shell profile for persistence
# ============================================================================

SHELL_PROFILE=""
if [ -n "$ZSH_VERSION" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_PROFILE="$HOME/.bash_profile"
fi

if [ -n "$SHELL_PROFILE" ] && [ -f "$SHELL_PROFILE" ]; then
    if ! grep -q "y2k-zones" "$SHELL_PROFILE" 2>/dev/null; then
        echo "" >> "$SHELL_PROFILE"
        echo "# Y2K Zones" >> "$SHELL_PROFILE"
        echo "export PATH=\"${BIN_DIR}:\$PATH\"" >> "$SHELL_PROFILE"
        echo -e "  ${YELLOW}ℹ Added to PATH in: $(basename $SHELL_PROFILE)${NC}"
    fi
fi

echo ""
echo -e "${BLUE}🎉 Ready to create Y2K magic! 🎀${NC}"
echo ""
