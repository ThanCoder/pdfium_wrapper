# https://github.com/ThanCoder/pdfium_wrapper.git


cmake_minimum_required(VERSION 3.15)

project(pdf_engine LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ============================================================
# PDFium
# ============================================================

if(NOT DEFINED PDFIUM_DIR)
    message(FATAL_ERROR
        "PDFIUM_DIR is required"
    )
endif()

message(STATUS "PDFIUM_DIR = ${PDFIUM_DIR}")

# ============================================================
# Sources
# ============================================================

set(PDF_ENGINE_SOURCES

    ffi/ffi_wrapper.h
    ffi/ffi_wrapper.cpp

    pdf/impl.cpp
    pdf/pdf_core.hpp
    pdf/pdf_core.cpp
    pdf/pdf_page.hpp
    pdf/pdf_page.cpp

    ffi/page_core_wrapper.cpp
    ffi/pdf_page_wrapper.cpp
    ffi/pdf_util_wrapper.cpp
)

# ============================================================
# Library type
# ============================================================

if(IOS)
    set(PDF_ENGINE_TYPE STATIC)
else()
    set(PDF_ENGINE_TYPE SHARED)
endif()

add_library(pdf_engine
    ${PDF_ENGINE_TYPE}
    ${PDF_ENGINE_SOURCES}
)

# ============================================================
# Includes
# ============================================================

target_include_directories(pdf_engine
    PRIVATE

    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/pdf

    ${PDFIUM_DIR}/include
)

set_target_properties(pdf_engine PROPERTIES
    POSITION_INDEPENDENT_CODE ON
)

# ============================================================
# Find PDFium
# ============================================================

if(WIN32)

    set(PDFIUM_LIBRARY
        "${PDFIUM_DIR}/lib/pdfium.lib"
    )

elseif(IOS)

    set(PDFIUM_LIBRARY
        "${PDFIUM_DIR}/lib/libpdfium.a"
    )

elseif(APPLE)

    set(PDFIUM_LIBRARY
        "${PDFIUM_DIR}/lib/libpdfium.dylib"
    )

else()

    set(PDFIUM_LIBRARY
        "${PDFIUM_DIR}/lib/libpdfium.so"
    )

endif()

if(NOT EXISTS "${PDFIUM_LIBRARY}")

    message(FATAL_ERROR
        "PDFium library not found:\n"
        "${PDFIUM_LIBRARY}"
    )

endif()

message(STATUS "PDFium library = ${PDFIUM_LIBRARY}")

# ============================================================
# Link PDFium
# ============================================================

target_link_libraries(pdf_engine
    PRIVATE
    "${PDFIUM_LIBRARY}"
)

# ============================================================
# Android
# ============================================================

if(ANDROID)

    target_link_libraries(pdf_engine
        PRIVATE
        log
        android
    )

endif()

# ============================================================
# Linux
# ============================================================

if(UNIX AND NOT APPLE AND NOT ANDROID)

    set_target_properties(pdf_engine PROPERTIES
        BUILD_WITH_INSTALL_RPATH TRUE
        INSTALL_RPATH "$ORIGIN"
    )

endif()

# ============================================================
# macOS
# ============================================================

if(APPLE AND NOT IOS)

    set_target_properties(pdf_engine PROPERTIES
        BUILD_WITH_INSTALL_RPATH TRUE
        INSTALL_RPATH "@loader_path"
    )

endif()

# ============================================================
# Summary
# ============================================================

message(STATUS "")
message(STATUS "========================================")
message(STATUS "PDF Engine")
message(STATUS "========================================")
message(STATUS "System      : ${CMAKE_SYSTEM_NAME}")
message(STATUS "Build type  : ${PDF_ENGINE_TYPE}")
message(STATUS "PDFium      : ${PDFIUM_LIBRARY}")
message(STATUS "========================================")
