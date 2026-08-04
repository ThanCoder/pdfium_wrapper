#!/usr/bin/env bash

set -euo pipefail

PDFIUM_VERSION="${PDFIUM_VERSION:-7988}"
PDFIUM_PACKAGE="${PDFIUM_PACKAGE:?PDFIUM_PACKAGE is required}"

ROOT_DIR="${GITHUB_WORKSPACE:-$(pwd)}"
PDFIUM_DIR="${ROOT_DIR}/.pdfium"

BASE_URL="https://github.com/bblanchon/pdfium-binaries/releases/download/chromium%2F${PDFIUM_VERSION}"

ARCHIVE="${PDFIUM_PACKAGE}.tgz"
URL="${BASE_URL}/${ARCHIVE}"

rm -rf "${PDFIUM_DIR}"
mkdir -p "${PDFIUM_DIR}"

echo "Downloading:"
echo "${URL}"

curl \
  --fail \
  --location \
  --retry 5 \
  --retry-all-errors \
  --connect-timeout 30 \
  --output "${ROOT_DIR}/${ARCHIVE}" \
  "${URL}"

echo "Extracting..."

tar \
  -xzf "${ROOT_DIR}/${ARCHIVE}" \
  -C "${PDFIUM_DIR}"

echo
echo "PDFium files:"
find "${PDFIUM_DIR}" -maxdepth 4 -type f | sort

echo
echo "PDFium root:"
find "${PDFIUM_DIR}" -maxdepth 2 -type d | sort