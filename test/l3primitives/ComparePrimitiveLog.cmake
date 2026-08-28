# In order to make per-primitive testing between terminal output and gold snapshots
# easier, we strip out everything before START and after END, and normalize newlines.

include(${CMAKE_CURRENT_LIST_DIR}/../CompareHelpers.cmake)

setup_comparison()

macro(extract_start_to_end var)
    string(FIND "${${var}}" "START\n" start_idx)
    if(NOT start_idx EQUAL -1)
        string(SUBSTRING "${${var}}" ${start_idx} -1 ${var})
    endif()
    string(FIND "${${var}}" "END\n" end_idx)
    if(NOT end_idx EQUAL -1)
        math(EXPR end_len "${end_idx} + 4")
        string(SUBSTRING "${${var}}" 0 ${end_len} ${var})
    endif()
endmacro()

extract_start_to_end(GENERATED_CONTENT)
extract_start_to_end(GOLD_CONTENT)

normalize_regex("[\n]+$" "\n")

compare_and_report()
