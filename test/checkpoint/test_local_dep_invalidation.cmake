# This test checks a fundamental operation: if you modify a file that was \input,
# the custom fmt file must be regenerated

if(NOT DEFINED NEMATEX_EXE OR NOT DEFINED TEST_DIR OR NOT DEFINED PLAIN_FMT)
    message(FATAL_ERROR "NEMATEX_EXE, TEST_DIR, and PLAIN_FMT must be defined")
endif()

file(REMOVE_RECURSE "${TEST_DIR}")
file(MAKE_DIRECTORY "${TEST_DIR}")

set(MACRO_FILE "${TEST_DIR}/local_macro.tex")
set(DOC_FILE "${TEST_DIR}/dep_test.tex")

file(WRITE "${MACRO_FILE}" "\\def\\mymacro{Version1}\n")
file(WRITE "${DOC_FILE}" "\\input local_macro.tex\n\\checkpointformat\nMacro: \\mymacro.\n\\bye\n")

execute_process(
    COMMAND "${NEMATEX_EXE}" --fmt=${PLAIN_FMT} --auto-checkpoint dep_test.tex
    WORKING_DIRECTORY "${TEST_DIR}"
    RESULT_VARIABLE res1
    OUTPUT_VARIABLE out1
    ERROR_VARIABLE err1
)

if(NOT res1 EQUAL 0 OR NOT EXISTS "${TEST_DIR}/dep_test__nematex__checkpointed.fmt")
    message(FATAL_ERROR "Cold run failed: ${out1}\n${err1}")
endif()

file(SHA256 "${TEST_DIR}/dep_test.dvi" HASH1)

# modify local macro file and rerun
file(WRITE "${MACRO_FILE}" "\\def\\mymacro{Version2Modified}\n")

execute_process(
    COMMAND "${NEMATEX_EXE}" --fmt=${PLAIN_FMT} --auto-checkpoint dep_test.tex
    WORKING_DIRECTORY "${TEST_DIR}"
    RESULT_VARIABLE res2
    OUTPUT_VARIABLE out2
    ERROR_VARIABLE err2
)

if(NOT res2 EQUAL 0)
    message(FATAL_ERROR "Rebuild failed with code ${res2}: ${out2}\n${err2}")
endif()

if("${out2}" MATCHES "\\[checkpoint\\] resuming from format")
    message(FATAL_ERROR "Local dependency modification should have triggered cold rebuild, but resumed from format!")
endif()

if(NOT "${out2}" MATCHES "\\[checkpoint\\] format written to")
    message(FATAL_ERROR "Expected cold rebuild notice: ${out2}")
endif()

file(SHA256 "${TEST_DIR}/dep_test.dvi" HASH2)

if("${HASH1}" STREQUAL "${HASH2}")
    message(FATAL_ERROR "DVI output should have changed when macro definition changed")
endif()
