#!/bin/bash

set -e

PDFIUM_ROOT="/home/thancoder/Documents/pdfium-linux-x64"

OUTPUT_DIR="dist_binaries"
OUTPUT_LIB_NAME="libpdf_engine"

echo "========================================"
echo "📦 Building Linux Desktop -> x64"
echo "========================================"

BUILD_DIR="build_temp_linux"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

cmake \
  -S . \
  -B "$BUILD_DIR" \
  -DCMAKE_BUILD_TYPE=MinSizeRel\
  -DPDFIUM_ROOT="$PDFIUM_ROOT"

cmake \
  --build "$BUILD_DIR" \
  --config MinSizeRel \
  --parallel

TARGET_SO="$BUILD_DIR/${OUTPUT_LIB_NAME}.so"
LINUX_OUT_DIR="$OUTPUT_DIR/linux/x64"

if [ -f "$TARGET_SO" ]; then

    mkdir -p "$LINUX_OUT_DIR"

    cp "$TARGET_SO" \
       "$LINUX_OUT_DIR/${OUTPUT_LIB_NAME}.so"

    strip --strip-all \
      "$LINUX_OUT_DIR/${OUTPUT_LIB_NAME}.so"

    echo "✅ Linux x64 done!"

else

    echo "❌ Linux x64 build failed!"
    exit 1

fi

rm -rf "$BUILD_DIR"

echo "----------------------------------------"
echo "🎉 Linux build completed!"
echo "📍 Output:"
ls -lh "$LINUX_OUT_DIR/${OUTPUT_LIB_NAME}.so"
echo "----------------------------------------"