# This test just makes sure that if the "Strict mode" requirements are not fulfilled, an 
# appropriate warning is thrown but that compilation finishes anyway with the fallback
# behavior

if(NOT DEFINED NEMATEX_EXE OR NOT DEFINED TEST_DIR OR NOT DEFINED PLAIN_FMT)
    message(FATAL_ERROR "NEMATEX_EXE, TEST_DIR, and PLAIN_FMT must be defined")
endif()

file(REMOVE_RECURSE "${TEST_DIR}")
file(MAKE_DIRECTORY "${TEST_DIR}")

set(DOC_FILE "${TEST_DIR}/fallback.tex")
file(WRITE "${DOC_FILE}" "\\def\\foo{bar}\n\\checkpointformat trailingtoken\nFallback Body.\n\\bye\n")

execute_process(
    COMMAND "${NEMATEX_EXE}" --fmt=${PLAIN_FMT} --auto-checkpoint fallback.tex
    WORKING_DIRECTORY "${TEST_DIR}"
    RESULT_VARIABLE res
    OUTPUT_VARIABLE out
    ERROR_VARIABLE err
)

if(NOT res EQUAL 0)
    message(FATAL_ERROR "Document with invariant violation should succeed with exit code 0, but failed with ${res}:\n${out}\n${err}")
endif()

if(EXISTS "${TEST_DIR}/fallback__nematex__checkpointed.fmt")
    message(FATAL_ERROR "Checkpoint format file should NOT be dumped when an invariant is violated")
endif()

if(NOT EXISTS "${TEST_DIR}/fallback.dvi")
    message(FATAL_ERROR "DVI output was not generated during one-pass fallback")
endif()

file(READ "${TEST_DIR}/fallback.log" LOG_CONTENT)
if(NOT "${LOG_CONTENT}" MATCHES "must be isolated on its line")
    message(FATAL_ERROR "Log does not contain expected DiagCheckpointError message:\n${LOG_CONTENT}")
endif()

if(NOT "${LOG_CONTENT}" MATCHES "\\[checkpoint\\] auto-checkpointing disabled")
    message(FATAL_ERROR "Log does not contain notice that auto-checkpointing was disabled:\n${LOG_CONTENT}")
endif()
