#!/usr/bin/env bash

set -euo pipefail

PDFIUM_VERSION="${PDFIUM_VERSION:-7988}"
PDFIUM_PACKAGE="${PDFIUM_PACKAGE:?PDFIUM_PACKAGE is required}"

PDFIUM_ROOT="${GITHUB_WORKSPACE}/.pdfium"
ARCHIVE="${GITHUB_WORKSPACE}/${PDFIUM_PACKAGE}.tgz"

BASE_URL="https://github.com/bblanchon/pdfium-binaries/releases/download/chromium%2F${PDFIUM_VERSION}"
URL="${BASE_URL}/${PDFIUM_PACKAGE}.tgz"

echo "========================================"
echo "Downloading PDFium"
echo "========================================"
echo "Version : ${PDFIUM_VERSION}"
echo "Package : ${PDFIUM_PACKAGE}"
echo "URL     : ${URL}"
echo

rm -rf "${PDFIUM_ROOT}"
rm -f "${ARCHIVE}"

mkdir -p "${PDFIUM_ROOT}"

curl \
  --fail \
  --location \
  --retry 5 \
  --retry-all-errors \
  --connect-timeout 30 \
  --output "${ARCHIVE}" \
  "${URL}"

echo
echo "Extracting..."

tar \
  -xzf "${ARCHIVE}" \
  -C "${PDFIUM_ROOT}"

echo
echo "========================================"
echo "PDFium files"
echo "========================================"

find "${PDFIUM_ROOT}" \
  -maxdepth 3 \
  -type f \
  -print \
  | sort

# ------------------------------------------------------------
# Validate expected structure
# ------------------------------------------------------------

if [ ! -d "${PDFIUM_ROOT}/include" ]; then
  echo
  echo "ERROR: PDFium include directory not found:"
  echo "${PDFIUM_ROOT}/include"
  exit 1
fi

if [ ! -d "${PDFIUM_ROOT}/lib" ]; then
  echo
  echo "ERROR: PDFium lib directory not found:"
  echo "${PDFIUM_ROOT}/lib"
  exit 1
fi

if [ ! -f "${PDFIUM_ROOT}/lib/libpdfium.so" ]; then
  echo
  echo "ERROR: libpdfium.so not found:"
  echo "${PDFIUM_ROOT}/lib/libpdfium.so"
  exit 1
fi

echo
echo "PDFIUM_ROOT=${PDFIUM_ROOT}"
echo "PDFIUM_INCLUDE=${PDFIUM_ROOT}/include"
echo "PDFIUM_LIB=${PDFIUM_ROOT}/lib"
echo "PDFIUM_LIBRARY=${PDFIUM_ROOT}/lib/libpdfium.so"

# ------------------------------------------------------------
# Export for GitHub Actions
# ------------------------------------------------------------

if [ -n "${GITHUB_ENV:-}" ]; then
  {
    echo "PDFIUM_ROOT=${PDFIUM_ROOT}"
    echo "PDFIUM_INCLUDE=${PDFIUM_ROOT}/include"
    echo "PDFIUM_LIB=${PDFIUM_ROOT}/lib"
    echo "PDFIUM_LIBRARY=${PDFIUM_ROOT}/lib/libpdfium.so"
  } >> "${GITHUB_ENV}"
fi