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

if(NOT CMAKE_BUILD_TYPE MATCHES "^(Debug|Coverage)$")
    add_compile_options(
        -O3
        -march=native
        -g
        -ffunction-sections
        -fdata-sections
    )
endif()

if(CMAKE_BUILD_TYPE MATCHES Debug)
    add_compile_options(
        -g
        -fno-omit-frame-pointer
        -fsanitize=address
    )
    add_link_options(-fsanitize=address)
endif()

if(CMAKE_BUILD_TYPE MATCHES Coverage)
    add_compile_options(
        -g
        -O0
        --coverage
    )
    add_link_options(--coverage)
endif()

add_compile_options(
    -Wall
    -Wextra
    -Wshadow 
    -Wpedantic
    # -Wconversion # turn this on for a laugh sometime
    -Wnon-virtual-dtor
    -Woverloaded-virtual
)
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

if(CMAKE_BUILD_TYPE MATCHES Coverage)
    find_program(GCOVR_PATH gcovr)

    if(GCOVR_PATH)
        add_custom_target(coverage
            COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure

            COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/coverage_report

            COMMAND ${GCOVR_PATH} 
                --html-nested ${CMAKE_BINARY_DIR}/coverage_report/index.html
                --root ${CMAKE_SOURCE_DIR}
                --object-directory ${CMAKE_BINARY_DIR}
                --exclude "${CMAKE_SOURCE_DIR}/extern/.*"
                --exclude "${CMAKE_SOURCE_DIR}/test/.*"
                --print-summary
            
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS ${PROJECT_NAME} formats
            COMMENT "Generating HTML coverage report in ${CMAKE_BINARY_DIR}/coverage_report/index.html"
        )
    else()
        message(WARNING "gcovr not found! The 'coverage' target will not be available.")
    endif()
endif()
