#!/bin/bash
# Generic build script for Evento white-label apps
# Usage: ./build.sh <config_file> [--dev|--release]
# Example: ./build.sh configs/melb2026.yaml --release

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Change to shell directory
cd "$SHELL_DIR"

# Check if config file is provided
if [ -z "$1" ]; then
  echo "❌ Error: Config file is required"
  echo ""
  echo "Usage: ./build.sh <config_file> [--dev|--release]"
  echo ""
  echo "Examples:"
  echo "  ./build.sh configs/melb2026.yaml --dev"
  echo "  ./build.sh configs/gc2026.yaml --release"
  echo ""
  echo "Available configs:"
  ls -1 configs/*.yaml 2>/dev/null | sed 's/^/  /' || echo "  (no config files found)"
  exit 1
fi

CONFIG_FILE="$1"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Error: Config file not found: $CONFIG_FILE"
  exit 1
fi

# Determine build mode (default to release if not specified)
BUILD_MODE="--release"
if [ "$2" == "--dev" ]; then
  BUILD_MODE="--dev"
elif [ "$2" == "--release" ]; then
  BUILD_MODE="--release"
fi

# Extract event name from config file
EVENT_NAME=$(basename "$CONFIG_FILE" .yaml)

echo "🚀 Building Evento app: $EVENT_NAME"
echo "📄 Config: $CONFIG_FILE"
echo "🔧 Mode: ${BUILD_MODE#--}"
echo ""

# Run the build script
dart run tool/build_app.dart "$CONFIG_FILE" "$BUILD_MODE"

echo ""
echo "✅ Build complete for $EVENT_NAME!"

