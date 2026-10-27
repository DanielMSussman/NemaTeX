# This test checks: that editing the preamble before the \checkpointformat primitive triggers a rebuild of the format file
#In our current setup, even changing a comment changes the "preamble"

if(NOT DEFINED NEMATEX_EXE OR NOT DEFINED TEST_DIR OR NOT DEFINED PLAIN_FMT)
    message(FATAL_ERROR "NEMATEX_EXE, TEST_DIR, and PLAIN_FMT must be defined")
endif()

file(REMOVE_RECURSE "${TEST_DIR}")
file(MAKE_DIRECTORY "${TEST_DIR}")

set(DOC_FILE "${TEST_DIR}/preamble_inv.tex")
file(WRITE "${DOC_FILE}" "% Original preamble comment\n\\def\\foo{bar}\n\\checkpointformat\nBody text.\n\\bye\n")

execute_process(
    COMMAND "${NEMATEX_EXE}" --fmt=${PLAIN_FMT} --auto-checkpoint preamble_inv.tex
    WORKING_DIRECTORY "${TEST_DIR}"
    RESULT_VARIABLE res1
    OUTPUT_VARIABLE out1
    ERROR_VARIABLE err1
)

if(NOT res1 EQUAL 0 OR NOT EXISTS "${TEST_DIR}/preamble_inv__nematex__checkpointed.fmt")
    message(FATAL_ERROR "Cold run failed: ${out1}\n${err1}")
endif()

# edit preamble comment, and run with the modified preamble
file(WRITE "${DOC_FILE}" "% Modified preamble comment that changes hash\n\\def\\foo{bar}\n\\checkpointformat\nBody text.\n\\bye\n")

execute_process(
    COMMAND "${NEMATEX_EXE}" --fmt=${PLAIN_FMT} --auto-checkpoint preamble_inv.tex
    WORKING_DIRECTORY "${TEST_DIR}"
    RESULT_VARIABLE res2
    OUTPUT_VARIABLE out2
    ERROR_VARIABLE err2
)

if(NOT res2 EQUAL 0)
    message(FATAL_ERROR "Rebuild failed with code ${res2}: ${out2}\n${err2}")
endif()

if("${out2}" MATCHES "\\[checkpoint\\] resuming from format")
    message(FATAL_ERROR "Preamble modification should NOT have resumed from format, but did!")
endif()

if(NOT "${out2}" MATCHES "\\[checkpoint\\] format written to")
    message(FATAL_ERROR "Expected cold rebuild to write updated checkpoint format: ${out2}")
endif()
