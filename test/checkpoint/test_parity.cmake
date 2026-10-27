# This test checks:
# (1) the cold run dumps the custom format and generates the output
# (2) the hot run reuses the format and generates the same output
# (3) preamble dimensions (from the "geometry" latex package) persist across the restart

if(NOT DEFINED NEMATEX_EXE OR NOT DEFINED TEST_DIR)
    message(FATAL_ERROR "NEMATEX_EXE and TEST_DIR must be defined")
endif()

file(REMOVE_RECURSE "${TEST_DIR}")
file(MAKE_DIRECTORY "${TEST_DIR}")

set(DOC_FILE "${TEST_DIR}/parity.tex")
# cool latex file, there
file(WRITE "${DOC_FILE}" "\\documentclass{article}\n\\usepackage[papersize={4in,7in},margin=1in]{geometry}\n\\checkpointformat\n\\begin{document}\n\\typeout{PARITY_PAPERWIDTH=\\the\\paperwidth}\n\\typeout{PARITY_PAPERHEIGHT=\\the\\paperheight}\nParity Test with Geometry: Hello World $E=mc^2$.\n\\end{document}\n")

execute_process(
    COMMAND "${NEMATEX_EXE}" --fmt=${LATEX_FMT} --auto-checkpoint parity.tex
    WORKING_DIRECTORY "${TEST_DIR}"
    RESULT_VARIABLE res_cold
    OUTPUT_VARIABLE out_cold
    ERROR_VARIABLE err_cold
)

if(NOT res_cold EQUAL 0)
    message(FATAL_ERROR "Cold run failed with exit code ${res_cold}:\n${out_cold}\n${err_cold}")
endif()

if(NOT EXISTS "${TEST_DIR}/parity__nematex__checkpointed.fmt")
    message(FATAL_ERROR "Cold run failed to produce checkpoint format file")
endif()

if(NOT EXISTS "${TEST_DIR}/parity.dvi")
    message(FATAL_ERROR "Cold run failed to produce DVI file")
endif()

file(READ "${TEST_DIR}/parity.log" log_cold)
if(NOT "${log_cold}" MATCHES "PARITY_PAPERWIDTH=289\\.07999pt")
    message(FATAL_ERROR "Cold run did not record expected geometry paperwidth:\n${log_cold}")
endif()

file(SHA256 "${TEST_DIR}/parity.dvi" COLD_DVI_HASH)
file(COPY_FILE "${TEST_DIR}/parity.dvi" "${TEST_DIR}/parity_cold.dvi")

execute_process(
    COMMAND "${NEMATEX_EXE}" --fmt=${LATEX_FMT} --auto-checkpoint parity.tex
    WORKING_DIRECTORY "${TEST_DIR}"
    RESULT_VARIABLE res_hot
    OUTPUT_VARIABLE out_hot
    ERROR_VARIABLE err_hot
)

if(NOT res_hot EQUAL 0)
    message(FATAL_ERROR "Hot run failed with exit code ${res_hot}:\n${out_hot}\n${err_hot}")
endif()

if(NOT "${out_hot}" MATCHES "\\[checkpoint\\] resuming from format")
    message(FATAL_ERROR "Hot run did not indicate format reuse in output:\n${out_hot}")
endif()

file(READ "${TEST_DIR}/parity.log" log_hot)
if(NOT "${log_hot}" MATCHES "PARITY_PAPERWIDTH=289\\.07999pt")
    message(FATAL_ERROR "Hot run did not preserve expected geometry paperwidth:\n${log_hot}")
endif()

file(SHA256 "${TEST_DIR}/parity.dvi" HOT_DVI_HASH)

if(NOT "${COLD_DVI_HASH}" STREQUAL "${HOT_DVI_HASH}")
    message(FATAL_ERROR "DVI outputs differ between cold and hot runs!\nCold hash: ${COLD_DVI_HASH}\nHot hash:  ${HOT_DVI_HASH}")
endif()
