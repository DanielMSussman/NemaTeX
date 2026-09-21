option(ENABLE_MACRO_PROFILER "Enable TeX macro execution profiling" OFF)
if(ENABLE_MACRO_PROFILER)
    add_compile_definitions(NEMATEX_PROFILE_MACROS)
endif()

add_custom_target(profiler
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/profiler
    COMMAND ${CMAKE_COMMAND} -S ${CMAKE_SOURCE_DIR} -B ${CMAKE_BINARY_DIR}/profiler -DENABLE_MACRO_PROFILER=ON
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR}/profiler
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/profiler/nematex ${CMAKE_BINARY_DIR}/nematex-profiler
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Building nematex-profiler with macro profiler enabled..."
    USES_TERMINAL
)

add_custom_target(noprofiler
    COMMAND ${CMAKE_COMMAND} -E rm -f ${CMAKE_BINARY_DIR}/nematex
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target nematex
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Rebuilding with no profiler..."
    USES_TERMINAL
)
