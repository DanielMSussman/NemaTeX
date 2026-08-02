cmake_minimum_required(VERSION 3.28)

project(nematex VERSION 0.6.0
    DESCRIPTION "tex82, but different"
    LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

find_package(PkgConfig QUIET REQUIRED)
pkg_check_modules(HarfBuzz REQUIRED IMPORTED_TARGET harfbuzz harfbuzz-subset)
pkg_check_modules(WOFF2 REQUIRED IMPORTED_TARGET libwoff2enc libwoff2common)

add_library(miniz_lib STATIC extern/miniz/miniz.c)
target_include_directories(miniz_lib PUBLIC extern/miniz)
target_compile_options(miniz_lib PRIVATE
    -O2
    -ffunction-sections
    -fdata-sections
)

if(NOT CMAKE_BUILD_TYPE MATCHES Debug)
    add_compile_options(
        -O3
        -march=native
        -g
        -ffunction-sections
        -fdata-sections
    )
endif()
add_compile_options(
    -Wall
    -Wextra
    -Wshadow 
    -Wno-deprecated-enum-enum-conversion # maybe someday we get rid of this...
)

if(CMAKE_BUILD_TYPE MATCHES Debug)
    add_compile_options(
        -g
        -fno-omit-frame-pointer
        -fsanitize=address
    )
    add_link_options(-fsanitize=address)
endif()

include_directories(
    ${CMAKE_SOURCE_DIR}/extern
    ${HarfBuzz_INCLUDE_DIRS}
)

add_subdirectory(src)

add_executable(${PROJECT_NAME} nematex.cpp)

target_link_libraries(${PROJECT_NAME} PUBLIC TeXCore Press)

target_link_options(${PROJECT_NAME} PRIVATE
    "-Wl,--gc-sections"
)

#We build some artifacts -- the fmt files -- alongside the main executable

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/slides.fmt
    COMMAND $<TARGET_FILE:${PROJECT_NAME}> " \\\\input slides \\\\dump" > /dev/null 2>&1
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    DEPENDS ${PROJECT_NAME} assets/formats/slides.tex ${CMAKE_BINARY_DIR}/ua2plain.fmt
    COMMENT "Generating slides.fmt..."
)

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/ua2plain.fmt
    COMMAND $<TARGET_FILE:${PROJECT_NAME}> " \\\\input ua2plain \\\\dump" > /dev/null 2>&1
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    DEPENDS ${PROJECT_NAME} assets/formats/ua2plain.tex assets/formats/math-definitions.tex assets/formats/hyphen.tex
    COMMENT "Generating ua2plain.fmt..."
)

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/plain.fmt
    COMMAND $<TARGET_FILE:${PROJECT_NAME}> " \\\\input plain \\\\dump" > /dev/null 2>&1
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    DEPENDS ${PROJECT_NAME} assets/formats/plain.tex assets/formats/hyphen.tex
    COMMENT "Generating plain.fmt..."
)

add_custom_target(formats ALL
    DEPENDS 
        ${CMAKE_BINARY_DIR}/plain.fmt 
        ${CMAKE_BINARY_DIR}/ua2plain.fmt
        ${CMAKE_BINARY_DIR}/slides.fmt
)


enable_testing()
add_subdirectory(test)
