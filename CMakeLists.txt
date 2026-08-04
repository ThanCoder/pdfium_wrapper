cmake_minimum_required(VERSION 3.20)

project(pdfium_wrapper LANGUAGES CXX)

# ============================================================
# Project
# ============================================================

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ============================================================
# Sources
# ============================================================

set(PDFIUM_WRAPPER_SOURCES

    src/ffi/ffi_wrapper.h
    src/ffi/ffi_wrapper.cpp
    src/ffi/page_core_wrapper.cpp
    src/ffi/pdf_page_wrapper.cpp
    src/ffi/pdf_util_wrapper.cpp

    src/pdf/impl.cpp
    src/pdf/pdf_core.hpp
    src/pdf/pdf_core.cpp
    src/pdf/pdf_page.hpp
    src/pdf/pdf_page.cpp
)

# ============================================================
# Library
# ============================================================

if(IOS)
    add_library(
        pdfium_wrapper
        STATIC
        ${PDFIUM_WRAPPER_SOURCES}
    )
else()
    add_library(
        pdfium_wrapper
        SHARED
        ${PDFIUM_WRAPPER_SOURCES}
    )
endif()

# ============================================================
# Output name
# ============================================================

set_target_properties(pdfium_wrapper PROPERTIES
    OUTPUT_NAME "pdfium_wrapper"
    POSITION_INDEPENDENT_CODE ON
)

# ============================================================
# Include
# ============================================================

target_include_directories(
    pdfium_wrapper
    PRIVATE

    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/pdf
    ${CMAKE_CURRENT_SOURCE_DIR}/src/ffi
)

# ============================================================
# PDFium
# ============================================================

if(NOT DEFINED PDFIUM_DIR)
    message(FATAL_ERROR
        "PDFIUM_DIR is required"
    )
endif()

message(STATUS "PDFIUM_DIR = ${PDFIUM_DIR}")

# PDFium package's CMake config/module
list(APPEND CMAKE_MODULE_PATH
    "${PDFIUM_DIR}"
)

find_package(PDFium REQUIRED)

target_link_libraries(
    pdfium_wrapper
    PRIVATE
    pdfium
)

# ============================================================
# Android
# ============================================================

if(ANDROID)

    message(STATUS "Building PDFium wrapper for Android")
    message(STATUS "ANDROID_ABI = ${ANDROID_ABI}")

    target_link_libraries(
        pdfium_wrapper
        PRIVATE
        log
        android
    )

endif()

# ============================================================
# Linux
# ============================================================

if(UNIX AND NOT APPLE AND NOT ANDROID)

    message(STATUS "Building PDFium wrapper for Linux")

    set_target_properties(
        pdfium_wrapper
        PROPERTIES
        BUILD_WITH_INSTALL_RPATH TRUE
        INSTALL_RPATH "$ORIGIN"
    )

endif()

# ============================================================
# macOS
# ============================================================

if(APPLE AND NOT IOS)

    message(STATUS "Building PDFium wrapper for macOS")

    set_target_properties(
        pdfium_wrapper
        PROPERTIES
        BUILD_WITH_INSTALL_RPATH TRUE
        INSTALL_RPATH "@loader_path"
    )

endif()

# ============================================================
# iOS
# ============================================================

if(IOS)

    message(STATUS "Building PDFium wrapper for iOS")

    set_target_properties(
        pdfium_wrapper
        PROPERTIES
        OUTPUT_NAME "pdfium_wrapper"
    )

endif()

# ============================================================
# Summary
# ============================================================

message(STATUS "")
message(STATUS "========================================")
message(STATUS "PDFium Wrapper")
message(STATUS "========================================")
message(STATUS "System      : ${CMAKE_SYSTEM_NAME}")
message(STATUS "C++         : ${CMAKE_CXX_STANDARD}")
message(STATUS "PDFium DIR  : ${PDFIUM_DIR}")
message(STATUS "========================================")
message(STATUS "")
