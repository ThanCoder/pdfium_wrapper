cmake_minimum_required(VERSION 3.20)

project(
    pdfium_wrapper
    VERSION 1.0.0
    LANGUAGES C CXX
)

set(CMAKE_C_STANDARD 11)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ============================================================
# PDFium
#
# Expected:
#
# PDFIUM_ROOT/
# ├── include/
# │   └── *.h
# │
# └── lib/
#     ├── libpdfium.so
#     └── *.so
#
# ============================================================

set(
    PDFIUM_ROOT
    ""
    CACHE PATH
    "Path to extracted PDFium"
)

if(NOT PDFIUM_ROOT)
    message(FATAL_ERROR
        "PDFIUM_ROOT is required"
    )
endif()

set(
    PDFIUM_INCLUDE_DIR
    "${PDFIUM_ROOT}/include"
)

set(
    PDFIUM_LIB_DIR
    "${PDFIUM_ROOT}/lib"
)

# ============================================================
# Validate PDFium
# ============================================================

if(NOT IS_DIRECTORY "${PDFIUM_INCLUDE_DIR}")
    message(FATAL_ERROR
        "PDFium include directory not found:\n"
        "  ${PDFIUM_INCLUDE_DIR}"
    )
endif()

if(NOT IS_DIRECTORY "${PDFIUM_LIB_DIR}")
    message(FATAL_ERROR
        "PDFium lib directory not found:\n"
        "  ${PDFIUM_LIB_DIR}"
    )
endif()

# ============================================================
# Find libpdfium
# ============================================================

find_library(
    PDFIUM_LIBRARY
    NAMES pdfium
    PATHS
        "${PDFIUM_LIB_DIR}"
    NO_DEFAULT_PATH
)

if(NOT PDFIUM_LIBRARY)
    message(FATAL_ERROR
        "libpdfium.so not found in:\n"
        "  ${PDFIUM_LIB_DIR}"
    )
endif()

message(STATUS "")
message(STATUS "========================================")
message(STATUS "PDFium configuration")
message(STATUS "========================================")
message(STATUS "PDFIUM_ROOT        = ${PDFIUM_ROOT}")
message(STATUS "PDFIUM_INCLUDE_DIR = ${PDFIUM_INCLUDE_DIR}")
message(STATUS "PDFIUM_LIB_DIR     = ${PDFIUM_LIB_DIR}")
message(STATUS "PDFIUM_LIBRARY     = ${PDFIUM_LIBRARY}")
message(STATUS "========================================")
message(STATUS "")

# ============================================================
# Imported PDFium library
# ============================================================

add_library(
    pdfium
    SHARED
    IMPORTED
    GLOBAL
)

set_target_properties(
    pdfium
    PROPERTIES

    IMPORTED_LOCATION
        "${PDFIUM_LIBRARY}"

    INTERFACE_INCLUDE_DIRECTORIES
        "${PDFIUM_INCLUDE_DIR}"
)

# ============================================================
# Wrapper source
# ============================================================

set(
    PDFIUM_WRAPPER_SOURCES

    src/ffi/ffi_wrapper.cpp
    src/ffi/page_core_wrapper.cpp
    src/ffi/pdf_page_wrapper.cpp
    src/ffi/pdf_util_wrapper.cpp

    src/pdf/impl.cpp
    src/pdf/pdf_core.cpp
    src/pdf/pdf_page.cpp
)

# ============================================================
# Wrapper shared library
# ============================================================

add_library(
    pdfium_wrapper
    SHARED

    ${PDFIUM_WRAPPER_SOURCES}
)

# ============================================================
# Include directories
# ============================================================

target_include_directories(
    pdfium_wrapper

    PRIVATE

        ${CMAKE_CURRENT_SOURCE_DIR}/src
        ${CMAKE_CURRENT_SOURCE_DIR}/src/ffi
        ${CMAKE_CURRENT_SOURCE_DIR}/src/pdf

        ${PDFIUM_INCLUDE_DIR}
)

# ============================================================
# Link PDFium
# ============================================================

target_link_libraries(
    pdfium_wrapper

    PRIVATE

        pdfium
)

# ============================================================
# Linux
# ============================================================

if(UNIX AND NOT APPLE)

    set_target_properties(
        pdfium_wrapper

        PROPERTIES

        BUILD_RPATH
            "$ORIGIN"

        INSTALL_RPATH
            "$ORIGIN"

        BUILD_WITH_INSTALL_RPATH
            TRUE
    )

endif()

# ============================================================
# macOS / iOS
# ============================================================

if(APPLE)

    set_target_properties(
        pdfium_wrapper

        PROPERTIES

        BUILD_RPATH
            "@loader_path"

        INSTALL_RPATH
            "@loader_path"
    )

endif()

# ============================================================
# Windows
# ============================================================

if(WIN32)

    set_target_properties(
        pdfium_wrapper

        PROPERTIES

        WINDOWS_EXPORT_ALL_SYMBOLS
            ON
    )

endif()

# ============================================================
# Output
# ============================================================

set_target_properties(
    pdfium_wrapper

    PROPERTIES

    OUTPUT_NAME
        "pdfium_wrapper"
)

# ============================================================
# Install
# ============================================================

include(GNUInstallDirs)

install(
    TARGETS
        pdfium_wrapper

    LIBRARY
        DESTINATION ${CMAKE_INSTALL_LIBDIR}

    RUNTIME
        DESTINATION ${CMAKE_INSTALL_BINDIR}

    ARCHIVE
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(
    DIRECTORY
        "${PDFIUM_INCLUDE_DIR}/"

    DESTINATION
        "${CMAKE_INSTALL_INCLUDEDIR}/pdfium"
)