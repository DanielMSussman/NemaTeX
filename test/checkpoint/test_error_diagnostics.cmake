# This test makes sure that, on a subsequent run, the scanner line numbers
# are up-to-date so that error messages still point to the correct places

if(NOT DEFINED NEMATEX_EXE OR NOT DEFINED TEST_DIR OR NOT DEFINED PLAIN_FMT)
    message(FATAL_ERROR "NEMATEX_EXE, TEST_DIR, and PLAIN_FMT must be defined")
endif()

file(REMOVE_RECURSE "${TEST_DIR}")
file(MAKE_DIRECTORY "${TEST_DIR}")

set(DOC_FILE "${TEST_DIR}/err_diag.tex")
file(WRITE "${DOC_FILE}" "\\nonstopmode\n\\def\\foo{bar}\n\\checkpointformat\nValid body for cold dump.\n\\bye\n")

execute_process(
    COMMAND "${NEMATEX_EXE}" --fmt=${PLAIN_FMT} --auto-checkpoint err_diag.tex
    WORKING_DIRECTORY "${TEST_DIR}"
    RESULT_VARIABLE res1
    OUTPUT_VARIABLE out1
    ERROR_VARIABLE err1
)

if(NOT res1 EQUAL 0 OR NOT EXISTS "${TEST_DIR}/err_diag__nematex__checkpointed.fmt")
    message(FATAL_ERROR "Cold run failed: ${out1}\n${err1}")
endif()

# will try tto use a non-existent macro to trigger the error, and rerun... since we've only changed
# the body, the custom fmt file will be used
file(WRITE "${DOC_FILE}" "\\nonstopmode\n\\def\\foo{bar}\n\\checkpointformat\n\\badcmd\nHello.\n\\bye\n")

execute_process(
    COMMAND "${NEMATEX_EXE}" --fmt=${PLAIN_FMT} --auto-checkpoint err_diag.tex
    WORKING_DIRECTORY "${TEST_DIR}"
    RESULT_VARIABLE res2
    OUTPUT_VARIABLE out2
    ERROR_VARIABLE err2
)

if(NOT EXISTS "${TEST_DIR}/err_diag.log")
    message(FATAL_ERROR "Log file was not generated: process may have crashed!")
endif()

file(READ "${TEST_DIR}/err_diag.log" LOG_CONTENT)

if(NOT "${LOG_CONTENT}" MATCHES "Undefined control sequence")
    message(FATAL_ERROR "Log does not report undefined control sequence:\n${LOG_CONTENT}")
endif()

if(NOT "${LOG_CONTENT}" MATCHES "l\\.4.*badcmd")
    message(FATAL_ERROR "Log does not show accurate line context:\n${LOG_CONTENT}")
endif()
