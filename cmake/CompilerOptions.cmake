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
