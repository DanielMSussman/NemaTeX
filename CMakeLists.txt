cmake_minimum_required(VERSION 3.28)

project(nematex VERSION 0.13.0
    DESCRIPTION "tex82, but different"
    LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(Dependencies)
include(CompilerOptions)
include(Profiler)
include(FileIndex)

set(CMAKE_LINKER_TYPE MOLD)
set(CMAKE_UNITY_BUILD ON)

add_subdirectory(src)

add_executable(${PROJECT_NAME} nematex.cpp)

target_link_libraries(${PROJECT_NAME} PUBLIC TeXCore Press nematex_compile_options)
target_precompile_headers(${PROJECT_NAME} REUSE_FROM CorePCH)
add_dependencies(${PROJECT_NAME} generate_file_indices)

include(Formats)

enable_testing()
add_subdirectory(test)

include(Coverage)
