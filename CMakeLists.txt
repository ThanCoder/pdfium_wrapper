cmake_minimum_required(VERSION 3.20)

project(
    pdfium_wrapper
    VERSION 1.0.0
    LANGUAGES C CXX
)

# ============================================================
# C / C++
# ============================================================

set(CMAKE_C_STANDARD 11)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)


# ============================================================
# PDFium
#
# Linux:
#
# PDFIUM_ROOT/
# └── lib/
#     ├── libpdfium.so
#     └── *.so
#
# Android:
#
# PDFIUM_ROOT/
# └── lib/
#     └── libpdfium.so
#
# Windows:
#
# PDFIUM_ROOT/
# ├── bin/
# │   └── pdfium.dll
# └── lib/
#     └── pdfium.lib
#
# macOS:
#
# PDFIUM_ROOT/
# └── lib/
#     └── libpdfium.dylib
#
# iOS:
#
# PDFIUM_ROOT/
# └── lib/
#     └── libpdfium.a
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


# ============================================================
# Normalize PDFium root
# ============================================================

get_filename_component(
    PDFIUM_ROOT
    "${PDFIUM_ROOT}"
    ABSOLUTE
)


set(
    PDFIUM_LIB_DIR
    "${PDFIUM_ROOT}/lib"
)


# ============================================================
# Validate PDFium root
# ============================================================

if(NOT IS_DIRECTORY "${PDFIUM_ROOT}")

    message(FATAL_ERROR
        "PDFium root directory not found:\n"
        "  ${PDFIUM_ROOT}"
    )

endif()


# ============================================================
# Print platform
# ============================================================

message(STATUS "")
message(STATUS "========================================")
message(STATUS "PDFium configuration")
message(STATUS "========================================")
message(STATUS "PDFIUM_ROOT = ${PDFIUM_ROOT}")
message(STATUS "Platform    = ${CMAKE_SYSTEM_NAME}")
message(STATUS "Processor   = ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "========================================")
message(STATUS "")


# ============================================================
# Windows
#
# Windows uses:
#
#   pdfium.dll   -> runtime
#   pdfium.lib   -> import library
#
# CMake must know both.
# ============================================================

if(WIN32)

    set(
        PDFIUM_DLL
        ""
        CACHE FILEPATH
        "Path to pdfium.dll"
    )

    set(
        PDFIUM_IMPLIB
        ""
        CACHE FILEPATH
        "Path to pdfium.lib"
    )


    # --------------------------------------------------------
    # Find pdfium.dll
    # --------------------------------------------------------

    if(NOT PDFIUM_DLL)

        find_file(
            PDFIUM_DLL_FOUND

            NAMES
                pdfium.dll

            PATHS
                "${PDFIUM_ROOT}/bin"
                "${PDFIUM_ROOT}/lib"
                "${PDFIUM_ROOT}"

            NO_DEFAULT_PATH
        )

        if(PDFIUM_DLL_FOUND)

            set(
                PDFIUM_DLL
                "${PDFIUM_DLL_FOUND}"
                CACHE FILEPATH
                "Path to pdfium.dll"
                FORCE
            )

        endif()

    endif()


    # --------------------------------------------------------
    # Find pdfium.lib
    # --------------------------------------------------------

    if(NOT PDFIUM_IMPLIB)

        find_file(
            PDFIUM_IMPLIB_FOUND

            NAMES
                pdfium.lib

            PATHS
                "${PDFIUM_ROOT}/lib"
                "${PDFIUM_ROOT}/bin"
                "${PDFIUM_ROOT}"

            NO_DEFAULT_PATH
        )

        if(PDFIUM_IMPLIB_FOUND)

            set(
                PDFIUM_IMPLIB
                "${PDFIUM_IMPLIB_FOUND}"
                CACHE FILEPATH
                "Path to pdfium.lib"
                FORCE
            )

        endif()

    endif()


    # --------------------------------------------------------
    # Validate
    # --------------------------------------------------------

    if(NOT PDFIUM_DLL)

        message(FATAL_ERROR
            "pdfium.dll not found in:\n"
            "  ${PDFIUM_ROOT}/bin\n"
            "  ${PDFIUM_ROOT}/lib\n"
            "  ${PDFIUM_ROOT}"
        )

    endif()


    if(NOT PDFIUM_IMPLIB)

        message(FATAL_ERROR
            "pdfium.lib not found in:\n"
            "  ${PDFIUM_ROOT}/lib\n"
            "  ${PDFIUM_ROOT}/bin\n"
            "  ${PDFIUM_ROOT}\n"
            "\n"
            "Windows requires pdfium.lib for linking."
        )

    endif()


    message(STATUS "PDFIUM_DLL    = ${PDFIUM_DLL}")
    message(STATUS "PDFIUM_IMPLIB  = ${PDFIUM_IMPLIB}")


    # --------------------------------------------------------
    # Imported PDFium
    # --------------------------------------------------------

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
        "${PDFIUM_DLL}"

        IMPORTED_IMPLIB
        "${PDFIUM_IMPLIB}"
    )


# ============================================================
# iOS
#
# PDFium is static:
#
#   libpdfium.a
#
# ============================================================

elseif(IOS)

    find_library(
        PDFIUM_LIBRARY

        NAMES
            pdfium
            libpdfium.a

        PATHS
            "${PDFIUM_LIB_DIR}"

        NO_DEFAULT_PATH
    )


    if(NOT PDFIUM_LIBRARY)

        message(FATAL_ERROR
            "libpdfium.a not found in:\n"
            "  ${PDFIUM_LIB_DIR}"
        )

    endif()


    message(STATUS
        "PDFIUM_LIBRARY = ${PDFIUM_LIBRARY}"
    )


    add_library(
        pdfium
        STATIC
        IMPORTED
        GLOBAL
    )


    set_target_properties(
        pdfium

        PROPERTIES

        IMPORTED_LOCATION
        "${PDFIUM_LIBRARY}"
    )


# ============================================================
# macOS
#
# PDFium:
#
#   libpdfium.dylib
#
# ============================================================

elseif(APPLE)

    find_library(
        PDFIUM_LIBRARY

        NAMES
            pdfium

        PATHS
            "${PDFIUM_LIB_DIR}"

        NO_DEFAULT_PATH
    )


    if(NOT PDFIUM_LIBRARY)

        message(FATAL_ERROR
            "libpdfium.dylib not found in:\n"
            "  ${PDFIUM_LIB_DIR}"
        )

    endif()


    message(STATUS
        "PDFIUM_LIBRARY = ${PDFIUM_LIBRARY}"
    )


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
    )


# ============================================================
# Linux / Android
#
# PDFium:
#
#   libpdfium.so
#
# ============================================================

else()

    find_library(
        PDFIUM_LIBRARY

        NAMES
            pdfium

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


    message(STATUS
        "PDFIUM_LIBRARY = ${PDFIUM_LIBRARY}"
    )


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
    )

endif()


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
# Wrapper library
#
# iOS:
#   STATIC
#
# Everything else:
#   SHARED
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
# Include directories
# ============================================================

target_include_directories(
    pdfium_wrapper

    PRIVATE

    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/src/ffi
    ${CMAKE_CURRENT_SOURCE_DIR}/src/pdf
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
# Android
#
# Keep PDFium beside wrapper.
#
# Runtime:
#
# libpdfium_wrapper.so
# libpdfium.so
#
# ============================================================

if(ANDROID)

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
# macOS
# ============================================================

if(APPLE AND NOT IOS)

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
# iOS
#
# Static library does not use runtime RPATH.
# ============================================================

if(IOS)

    set_target_properties(
        pdfium_wrapper

        PROPERTIES

        POSITION_INDEPENDENT_CODE
        ON
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


    # --------------------------------------------------------
    # Put wrapper DLL beside pdfium.dll
    # --------------------------------------------------------

    add_custom_command(
        TARGET pdfium_wrapper
        POST_BUILD

        COMMAND
            ${CMAKE_COMMAND}
            -E copy_if_different

            "${PDFIUM_DLL}"

            "$<TARGET_FILE_DIR:pdfium_wrapper>/pdfium.dll"

        COMMENT
            "Copying pdfium.dll beside pdfium_wrapper.dll"
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


if(IOS)

    install(
        TARGETS
        pdfium_wrapper

        ARCHIVE
        DESTINATION
        ${CMAKE_INSTALL_LIBDIR}
    )

else()

    install(
        TARGETS
        pdfium_wrapper

        LIBRARY
        DESTINATION
        ${CMAKE_INSTALL_LIBDIR}

        RUNTIME
        DESTINATION
        ${CMAKE_INSTALL_BINDIR}

        ARCHIVE
        DESTINATION
        ${CMAKE_INSTALL_LIBDIR}
    )

endif()
