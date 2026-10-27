find_package(PkgConfig QUIET REQUIRED)
pkg_check_modules(HarfBuzz REQUIRED IMPORTED_TARGET harfbuzz harfbuzz-subset)
pkg_check_modules(WOFF2 REQUIRED IMPORTED_TARGET libwoff2enc libwoff2common)

set(LIBDEFLATE_BUILD_STATIC_LIB ON CACHE BOOL "" FORCE)
set(LIBDEFLATE_BUILD_SHARED_LIB OFF CACHE BOOL "" FORCE)
set(LIBDEFLATE_BUILD_GZIP OFF CACHE BOOL "" FORCE)
set(LIBDEFLATE_BUILD_TESTS OFF CACHE BOOL "" FORCE)

cmake_policy(SET CMP0069 NEW)
add_subdirectory(${CMAKE_SOURCE_DIR}/extern/libdeflate EXCLUDE_FROM_ALL)

find_package(Python3 REQUIRED COMPONENTS Interpreter)
