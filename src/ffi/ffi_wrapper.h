#ifndef PDF_ENGINE_H
#define PDF_ENGINE_H

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#if defined(_WIN32) || defined(__CYGWIN__)
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

// ============================================================
// PDFium
// ============================================================

FFI_PLUGIN_EXPORT
void pdfium_init();

FFI_PLUGIN_EXPORT
void pdfium_destroy();

// ============================================================
// PDF Core
// ============================================================

typedef struct {
  float width;
  float height;
} Page_Size_Data;

typedef struct pdf_core_s *pdf_core_t;

FFI_PLUGIN_EXPORT
pdf_core_t pdf_core_create();

FFI_PLUGIN_EXPORT
void pdf_core_destroy(pdf_core_t pdf_core_ptr);

FFI_PLUGIN_EXPORT
bool pdf_core_openFile(pdf_core_t pdf_core_ptr, const char *path,
                       const char *password);

FFI_PLUGIN_EXPORT
bool pdf_core_openMemoryRaw(pdf_core_t pdf_core_ptr,
                            const unsigned char *buffer, int buffer_size,
                            const char *password);

FFI_PLUGIN_EXPORT
bool pdf_core_openMemory64Raw(pdf_core_t pdf_core_ptr,
                              const unsigned char *buffer, int buffer_size,
                              const char *password);

FFI_PLUGIN_EXPORT
bool pdf_core_fileOpened(pdf_core_t pdf_core_ptr);

FFI_PLUGIN_EXPORT
int pdf_core_getPageCount(pdf_core_t pdf_core_ptr);

// ============================================================
// Page Size
// ============================================================

typedef struct page_size_data_s *page_size_data_t;

FFI_PLUGIN_EXPORT
page_size_data_t pdf_core_getAllPageSizes(pdf_core_t pdf_core_ptr,
                                          int *out_count_ptr);

FFI_PLUGIN_EXPORT
void pdf_core_free_getAllPageSizes(page_size_data_t page_size_data_ptr);

// ============================================================
// PDF Page
// ============================================================

typedef struct pdf_page_s *pdf_page_t;

FFI_PLUGIN_EXPORT
pdf_page_t pdf_page_create(pdf_core_t pdf_core_ptr, int page_index);

FFI_PLUGIN_EXPORT
void pdf_page_destroy(pdf_page_t pdf_page_ptr);

FFI_PLUGIN_EXPORT
bool pdf_page_isVaild(pdf_page_t pdf_page_ptr);

FFI_PLUGIN_EXPORT
double pdf_page_getWidth(pdf_page_t pdf_page_ptr);

FFI_PLUGIN_EXPORT
double pdf_page_getHeight(pdf_page_t pdf_page_ptr);

FFI_PLUGIN_EXPORT
double pdf_page_getWidthF(pdf_page_t pdf_page_ptr);

FFI_PLUGIN_EXPORT
double pdf_page_getHeightF(pdf_page_t pdf_page_ptr);

// ============================================================
// Save
// ============================================================

FFI_PLUGIN_EXPORT
bool pdf_page_saveAsPngWH(pdf_page_t pdf_page_ptr, const char *out_path,
                          int width, int height);

FFI_PLUGIN_EXPORT
bool pdf_page_saveAsJpgWH(pdf_page_t pdf_page_ptr, const char *out_path,
                          int width, int height, int quality);

// ============================================================
// Render JPEG
// ============================================================

FFI_PLUGIN_EXPORT
unsigned char *pdf_page_renderToJpegWH(pdf_page_t pdf_page_ptr, int *data_size,
                                       int width, int height, int quality);

FFI_PLUGIN_EXPORT
void pdf_page_free_renderToJpegWH(unsigned char *render_jpg_buff);

// ============================================================
// Render PNG
// ============================================================

FFI_PLUGIN_EXPORT
unsigned char *pdf_page_renderToPngWH(pdf_page_t pdf_page_ptr, int *data_size,
                                      int width, int height);

FFI_PLUGIN_EXPORT
void pdf_page_free_renderToPngWH(unsigned char *render_png_buff);

// ============================================================
// PDF Util
// ============================================================

FFI_PLUGIN_EXPORT
bool pdf_util_saveJpgWithIndex(const char *pdf_path, const char *password,
                               const char *out_path, int page_index, int width,
                               int height, int quality);

FFI_PLUGIN_EXPORT
bool pdf_util_savePngWithIndex(const char *pdf_path, const char *password,
                               const char *out_path, int page_index, int width,
                               int height);

#ifdef __cplusplus
}
#endif

#endif // PDF_ENGINE_H