#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# Android Configuration
# ============================================================

API_LEVEL="21"

OUTPUT_DIR="dist_binaries/android"
OUTPUT_LIB_NAME="libpdf_engine"

ANDROID_ABIS=(
    "arm64-v8a"
    "armeabi-v7a"
)

# ============================================================
# Android SDK
# ============================================================

if [[ -z "${ANDROID_HOME:-}" ]]; then
    if [[ -d "$HOME/Android/Sdk" ]]; then
        export ANDROID_HOME="$HOME/Android/Sdk"
    else
        echo "❌ Android SDK not found."
        echo "Please set ANDROID_HOME."
        exit 1
    fi
fi

# ============================================================
# Android NDK
# ============================================================

if [[ -n "${ANDROID_NDK_HOME:-}" ]]; then

    NDK_PATH="$ANDROID_NDK_HOME"

elif [[ -n "${ANDROID_NDK_ROOT:-}" ]]; then

    NDK_PATH="$ANDROID_NDK_ROOT"

else

    NDK_PATH="$(
        find "$ANDROID_HOME/ndk" \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
            | sort -V \
            | tail -n 1
    )"

fi

if [[ -z "${NDK_PATH:-}" || ! -d "$NDK_PATH" ]]; then
    echo "❌ Android NDK not found."
    exit 1
fi

ANDROID_TOOLCHAIN="$NDK_PATH/build/cmake/android.toolchain.cmake"

if [[ ! -f "$ANDROID_TOOLCHAIN" ]]; then
    echo "❌ Android CMake toolchain not found:"
    echo "$ANDROID_TOOLCHAIN"
    exit 1
fi

# ============================================================
# Check CMake
# ============================================================

if ! command -v cmake >/dev/null 2>&1; then
    echo "❌ CMake not found."
    exit 1
fi

# ============================================================
# Start
# ============================================================

echo "----------------------------------------"
echo "🚀 Android Build"
echo "----------------------------------------"
echo "SDK : $ANDROID_HOME"
echo "NDK : $NDK_PATH"
echo "API : $API_LEVEL"
echo "----------------------------------------"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# ============================================================
# Build Android ABIs
# ============================================================

for ABI in "${ANDROID_ABIS[@]}"; do

    echo ""
    echo "========================================"
    echo "📦 Building Android -> $ABI"
    echo "========================================"

    BUILD_DIR="build_temp_android_${ABI}"
    OUT_DIR="$OUTPUT_DIR/$ABI"

    rm -rf "$BUILD_DIR"
    mkdir -p "$OUT_DIR"

    # --------------------------------------------------------
    # CMake Configure
    # --------------------------------------------------------

    cmake \
        -S . \
        -B "$BUILD_DIR" \
        -DCMAKE_SYSTEM_NAME=Android \
        -DCMAKE_TOOLCHAIN_FILE="$ANDROID_TOOLCHAIN" \
        -DANDROID_ABI="$ABI" \
        -DANDROID_PLATFORM="android-$API_LEVEL" \
        -DCMAKE_BUILD_TYPE=MinSizeRel

    # --------------------------------------------------------
    # Build
    # --------------------------------------------------------

    cmake \
        --build "$BUILD_DIR" \
        --config MinSizeRel \
        --parallel

    # --------------------------------------------------------
    # Find output
    # --------------------------------------------------------

    TARGET_SO="$BUILD_DIR/${OUTPUT_LIB_NAME}.so"

    if [[ ! -f "$TARGET_SO" ]]; then
        echo "❌ Build failed for $ABI"
        rm -rf "$BUILD_DIR"
        exit 1
    fi

    # --------------------------------------------------------
    # Copy
    # --------------------------------------------------------

    cp \
        "$TARGET_SO" \
        "$OUT_DIR/${OUTPUT_LIB_NAME}.so"

    # --------------------------------------------------------
    # Strip
    # --------------------------------------------------------

    LLVM_STRIP="$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip"

    if [[ -x "$LLVM_STRIP" ]]; then

        "$LLVM_STRIP" \
            --strip-unneeded \
            "$OUT_DIR/${OUTPUT_LIB_NAME}.so"

    else

        echo "⚠️ llvm-strip not found."
        echo "Skipping strip."

    fi

    echo "✅ Android $ABI done."

    file "$OUT_DIR/${OUTPUT_LIB_NAME}.so"

    rm -rf "$BUILD_DIR"

done

# ============================================================
# Summary
# ============================================================

echo ""
echo "----------------------------------------"
echo "🎉 Android build completed!"
echo "----------------------------------------"

find "$OUTPUT_DIR" \
    -type f \
    -name "*.so" \
    -exec ls -lh {} \;

echo "----------------------------------------"