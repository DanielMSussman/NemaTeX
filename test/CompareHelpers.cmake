# Helper functions for comparing generated log files (e.g.) with a normalized standard one

macro(setup_comparison)
    if(NOT DEFINED GENERATED_FILE OR NOT DEFINED GOLD_FILE)
        message(FATAL_ERROR "Usage: cmake -DGENERATED_FILE=... -DGOLD_FILE=... -P <Script>.cmake")
    endif()

    if(NOT EXISTS "${GENERATED_FILE}")
        message(FATAL_ERROR "File not found: ${GENERATED_FILE}")
    endif()
    if(NOT EXISTS "${GOLD_FILE}")
        message(FATAL_ERROR "File not found: ${GOLD_FILE}")
    endif()

    file(READ "${GENERATED_FILE}" GENERATED_CONTENT)
    file(READ "${GOLD_FILE}" GOLD_CONTENT)

    string(REPLACE "\r\n" "\n" GENERATED_CONTENT "${GENERATED_CONTENT}")
    string(REPLACE "\r\n" "\n" GOLD_CONTENT "${GOLD_CONTENT}")
endmacro()

macro(compare_and_report)
    if(NOT "${GENERATED_CONTENT}" STREQUAL "${GOLD_CONTENT}")
        get_filename_component(GEN_BASENAME "${GENERATED_FILE}" NAME_WE)
        set(NORMALIZED_GENERATED_PATH "${CMAKE_BINARY_DIR}/Testing/Temporary/${GEN_BASENAME}_generated_normalized.txt")
        set(NORMALIZED_GOLD_PATH "${CMAKE_BINARY_DIR}/Testing/Temporary/${GEN_BASENAME}_gold_normalized.txt")
        file(WRITE "${NORMALIZED_GENERATED_PATH}" "${GENERATED_CONTENT}")
        file(WRITE "${NORMALIZED_GOLD_PATH}" "${GOLD_CONTENT}")
        
        message(FATAL_ERROR "Files differ after normalization.\n"
                            "The normalized versions have been written for inspection:\n"
                            "  - ${NORMALIZED_GENERATED_PATH}\n"
                            "  - ${NORMALIZED_GOLD_PATH}\n"
                            "Please run a diff tool on these two files to see the discrepancy.")
    else()
        message(STATUS "Files match after normalization.")
    endif()
endmacro()

function(normalize_regex REGEX_PATTERN REPLACEMENT_STRING)
    string(REGEX REPLACE "${REGEX_PATTERN}" "${REPLACEMENT_STRING}" GENERATED_TMP "${GENERATED_CONTENT}")
    string(REGEX REPLACE "${REGEX_PATTERN}" "${REPLACEMENT_STRING}" GOLD_TMP "${GOLD_CONTENT}")
    set(GENERATED_CONTENT "${GENERATED_TMP}" PARENT_SCOPE)
    set(GOLD_CONTENT "${GOLD_TMP}" PARENT_SCOPE)
endfunction()

function(normalize_string EXACT_STRING REPLACEMENT_STRING)
    string(REPLACE "${EXACT_STRING}" "${REPLACEMENT_STRING}" GENERATED_TMP "${GENERATED_CONTENT}")
    string(REPLACE "${EXACT_STRING}" "${REPLACEMENT_STRING}" GOLD_TMP "${GOLD_CONTENT}")
    set(GENERATED_CONTENT "${GENERATED_TMP}" PARENT_SCOPE)
    set(GOLD_CONTENT "${GOLD_TMP}" PARENT_SCOPE)
endfunction()

include(${CMAKE_CURRENT_LIST_DIR}/TripTestNormalizations.cmake)
