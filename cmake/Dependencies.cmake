find_package(PkgConfig QUIET REQUIRED)
pkg_check_modules(HarfBuzz REQUIRED IMPORTED_TARGET harfbuzz harfbuzz-subset)
pkg_check_modules(WOFF2 REQUIRED IMPORTED_TARGET libwoff2enc libwoff2common)

add_library(miniz_lib STATIC ${CMAKE_SOURCE_DIR}/extern/miniz/miniz.c)
target_include_directories(miniz_lib PUBLIC ${CMAKE_SOURCE_DIR}/extern/miniz)
target_compile_options(miniz_lib PRIVATE
    -O2
    -ffunction-sections
    -fdata-sections
)

include_directories(
    ${CMAKE_SOURCE_DIR}/extern
    ${HarfBuzz_INCLUDE_DIRS}
)

find_package(Python3 REQUIRED COMPONENTS Interpreter)
