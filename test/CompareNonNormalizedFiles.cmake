# For non-normalized files, we do a fast byte comparison, and only if that fails do we fall back to the same setup/compare/report mechanism used elsewhere
include(${CMAKE_CURRENT_LIST_DIR}/CompareHelpers.cmake)

if(NOT DEFINED GENERATED_FILE OR NOT DEFINED GOLD_FILE)
    message(FATAL_ERROR "Usage: cmake -DGENERATED_FILE=... -DGOLD_FILE=... -P <Script>.cmake")
endif()

execute_process(
    COMMAND ${CMAKE_COMMAND} -E compare_files "${GENERATED_FILE}" "${GOLD_FILE}"
    RESULT_VARIABLE FAST_COMPARE_RESULT
    OUTPUT_QUIET
    ERROR_QUIET
)

if(FAST_COMPARE_RESULT EQUAL 0)
    return()
endif()

setup_comparison()
compare_and_report()
