# The test checks an important property: editing the file *after* the checkpoint should
# not trigger a custom format file rebuild

if(NOT DEFINED NEMATEX_EXE OR NOT DEFINED TEST_DIR OR NOT DEFINED PLAIN_FMT)
    message(FATAL_ERROR "NEMATEX_EXE, TEST_DIR, and PLAIN_FMT must be defined")
endif()

file(REMOVE_RECURSE "${TEST_DIR}")
file(MAKE_DIRECTORY "${TEST_DIR}")

set(DOC_FILE "${TEST_DIR}/body_edit.tex")
file(WRITE "${DOC_FILE}" "\\def\\msg{Initial body sentence.}\n\\checkpointformat\n\\msg\n\\bye\n")

execute_process(
    COMMAND "${NEMATEX_EXE}" --fmt=${PLAIN_FMT} --auto-checkpoint body_edit.tex
    WORKING_DIRECTORY "${TEST_DIR}"
    RESULT_VARIABLE res1
    OUTPUT_VARIABLE out1
    ERROR_VARIABLE err1
)

if(NOT res1 EQUAL 0 OR NOT EXISTS "${TEST_DIR}/body_edit__nematex__checkpointed.fmt")
    message(FATAL_ERROR "Cold run failed: ${out1}\n${err1}")
endif()

file(SHA256 "${TEST_DIR}/body_edit.dvi" HASH1)

# modify document body, and re-run
file(WRITE "${DOC_FILE}" "\\def\\msg{Initial body sentence.}\n\\checkpointformat\nModified body with different text and formulas $x^2+y^2=z^2$.\n\\bye\n")

execute_process(
    COMMAND "${NEMATEX_EXE}" --fmt=${PLAIN_FMT} --auto-checkpoint body_edit.tex
    WORKING_DIRECTORY "${TEST_DIR}"
    RESULT_VARIABLE res2
    OUTPUT_VARIABLE out2
    ERROR_VARIABLE err2
)

if(NOT res2 EQUAL 0)
    message(FATAL_ERROR "Hot run failed with code ${res2}: ${out2}\n${err2}")
endif()

if(NOT "${out2}" MATCHES "\\[checkpoint\\] resuming from format")
    message(FATAL_ERROR "Expected hot resumption indicator not found in output: ${out2}")
endif()

file(SHA256 "${TEST_DIR}/body_edit.dvi" HASH2)

if("${HASH1}" STREQUAL "${HASH2}")
    message(FATAL_ERROR "DVI output should have changed after editing body text, but remained identical")
endif()
