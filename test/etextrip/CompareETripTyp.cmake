# generate a typ from the dvi, and compare it

include(${CMAKE_CURRENT_LIST_DIR}/../CompareHelpers.cmake)

if(NOT DEFINED DVITYPE_EXECUTABLE OR NOT DEFINED GENERATED_DVI OR NOT DEFINED GOLD_TYP)
    message(FATAL_ERROR "Usage: cmake -DDVITYPE_EXECUTABLE=... -DGENERATED_DVI=... -DGOLD_TYP=... -DTMP_DIR=... -P CompareETripTyp.cmake")
endif()

if(NOT EXISTS "${GENERATED_DVI}")
    message(FATAL_ERROR "Generated DVI file not found: ${GENERATED_DVI}")
endif()

if(NOT DEFINED TMP_DIR)
    set(TMP_DIR "${CMAKE_BINARY_DIR}/Testing/Temporary")
endif()
file(MAKE_DIRECTORY "${TMP_DIR}")

set(GENERATED_TYP "${TMP_DIR}/etrip_generated.typ")

execute_process(
    COMMAND ${DVITYPE_EXECUTABLE} -output-level=2 -page-start=*.*.*.*.*.*.*.*.*.* -dpi=72.27 -magnification=0 ${GENERATED_DVI}
    OUTPUT_FILE ${GENERATED_TYP}
    RESULT_VARIABLE DVITYPE_RESULT
)

if(NOT DVITYPE_RESULT EQUAL 0)
    message(FATAL_ERROR "dvitype failed with exit code ${DVITYPE_RESULT}")
endif()

set(GENERATED_FILE "${GENERATED_TYP}")
set(GOLD_FILE "${GOLD_TYP}")

setup_comparison()

normalize_regex("^This is DVItype, Version [^\n]*" "This is DVItype [version mocked]")
normalize_regex("' TeX output [^\n]*'" "' TeX output [timestamp mocked]'")

compare_and_report()
