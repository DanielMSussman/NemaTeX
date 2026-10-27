# I'm slowly learning about modern cmake... here's the interface library for all compiler
#flags, definitions, and link options for nematex targets
add_library(nematex_compile_options INTERFACE)

# require C++23 standard for any target linking this interface
target_compile_features(nematex_compile_options INTERFACE cxx_std_23)

target_include_directories(nematex_compile_options INTERFACE
    ${CMAKE_SOURCE_DIR}/extern
)

target_compile_definitions(nematex_compile_options INTERFACE
    _REENTRANT
    $<$<BOOL:${ENABLE_MACRO_PROFILER}>:NEMATEX_PROFILE_MACROS>
)


target_compile_options(nematex_compile_options INTERFACE
    $<$<COMPILE_LANGUAGE:CXX>:
        -Wall
        -Wextra
        -Wshadow
        -Wpedantic
        -Wnon-virtual-dtor
        -Woverloaded-virtual
    >
    # release / default 
    $<$<NOT:$<CONFIG:Debug,Coverage>>:
        -O3
        -march=native
        -g
        -ffunction-sections
        -fdata-sections
        -fno-exceptions
        -fno-rtti
    >
    $<$<CONFIG:Debug>:
        -g
        -fno-omit-frame-pointer
        -fsanitize=address
    >
    $<$<CONFIG:Coverage>:
        -g
        -O0
        --coverage
    >
)

target_link_options(nematex_compile_options INTERFACE
    $<$<CONFIG:Debug>:
        -fsanitize=address
    >
    $<$<CONFIG:Coverage>:
        --coverage
    >
    $<$<NOT:$<CONFIG:Debug,Coverage>>:
        -Wl,--gc-sections
    >
)

