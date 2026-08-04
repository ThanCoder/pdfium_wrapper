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
# Options
# ============================================================

set(PDFIUM_ROOT
    ""
    CACHE PATH
    "PDFium extracted root directory"
)

if(NOT PDFIUM_ROOT)
    message(FATAL_ERROR
        "PDFIUM_ROOT is required."
    )
endif()

# ============================================================
# PDFium include directory
# ============================================================

set(PDFIUM_INCLUDE_DIR
    "${PDFIUM_ROOT}/include"
)

if(NOT EXISTS "${PDFIUM_INCLUDE_DIR}")
    message(FATAL_ERROR
        "PDFium include directory not found:\n"
        "  ${PDFIUM_INCLUDE_DIR}"
    )
endif()

# ============================================================
# Find PDFium binary
# ============================================================

if(WIN32)

    set(PDFIUM_CANDIDATES
        "${PDFIUM_ROOT}/bin/pdfium.dll"
        "${PDFIUM_ROOT}/lib/pdfium.dll"
        "${PDFIUM_ROOT}/pdfium.dll"
    )

elseif(APPLE)

    set(PDFIUM_CANDIDATES
        "${PDFIUM_ROOT}/lib/libpdfium.dylib"
        "${PDFIUM_ROOT}/bin/libpdfium.dylib"
        "${PDFIUM_ROOT}/lib/pdfium.dylib"
        "${PDFIUM_ROOT}/lib/libpdfium.a"
    )

else()

    set(PDFIUM_CANDIDATES
        "${PDFIUM_ROOT}/lib/libpdfium.so"
        "${PDFIUM_ROOT}/lib/libpdfium.a"
        "${PDFIUM_ROOT}/bin/libpdfium.so"
    )

endif()

set(PDFIUM_LIBRARY "")

foreach(candidate ${PDFIUM_CANDIDATES})
    if(EXISTS "${candidate}")
        set(PDFIUM_LIBRARY "${candidate}")
        break()
    endif()
endforeach()

if(NOT PDFIUM_LIBRARY)
    message(FATAL_ERROR
        "Could not find PDFium library under:\n"
        "  ${PDFIUM_ROOT}\n"
        "Expected one of:\n"
        "${PDFIUM_CANDIDATES}"
    )
endif()

message(STATUS "========================================")
message(STATUS "PDFium configuration")
message(STATUS "========================================")
message(STATUS "PDFIUM_ROOT         = ${PDFIUM_ROOT}")
message(STATUS "PDFIUM_INCLUDE_DIR  = ${PDFIUM_INCLUDE_DIR}")
message(STATUS "PDFIUM_LIBRARY      = ${PDFIUM_LIBRARY}")
message(STATUS "========================================")

# ============================================================
# Imported PDFium
# ============================================================

if(PDFIUM_LIBRARY MATCHES "\\.a$")

    add_library(pdfium STATIC IMPORTED GLOBAL)

else()

    add_library(pdfium SHARED IMPORTED GLOBAL)

endif()

set_target_properties(pdfium PROPERTIES

    IMPORTED_LOCATION
    "${PDFIUM_LIBRARY}"

    INTERFACE_INCLUDE_DIRECTORIES
    "${PDFIUM_INCLUDE_DIR}"
)

# ============================================================
# Wrapper source
# ============================================================

set(WRAPPER_SOURCES

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
# ============================================================

add_library(pdfium_wrapper SHARED
    ${WRAPPER_SOURCES}
)

target_include_directories(pdfium_wrapper

    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/ffi
    ${CMAKE_CURRENT_SOURCE_DIR}/src/pdf

    PRIVATE
    ${PDFIUM_INCLUDE_DIR}
)

target_link_libraries(pdfium_wrapper
    PRIVATE
    pdfium
)

# ============================================================
# Platform settings
# ============================================================

if(UNIX AND NOT APPLE)

    set_target_properties(pdfium_wrapper PROPERTIES
        BUILD_RPATH "$ORIGIN"
        INSTALL_RPATH "$ORIGIN"
    )

elseif(APPLE)

    set_target_properties(pdfium_wrapper PROPERTIES
        BUILD_RPATH "@loader_path"
        INSTALL_RPATH "@loader_path"
    )

elseif(WIN32)

    set_target_properties(pdfium_wrapper PROPERTIES
        WINDOWS_EXPORT_ALL_SYMBOLS ON
    )

endif()

# ============================================================
# Output
# ============================================================

set_target_properties(pdfium_wrapper PROPERTIES

    OUTPUT_NAME
    "pdfium_wrapper"

    VERSION
    ${PROJECT_VERSION}

    SOVERSION
    1
)

# ============================================================
# Install
# ============================================================

include(GNUInstallDirs)

install(
    TARGETS pdfium_wrapper
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(
    FILES
    src/ffi/ffi_wrapper.h
    DESTINATION
    ${CMAKE_INSTALL_INCLUDEDIR}/pdfium_wrapper
)
