# This test is kind of interesting... LaTeX often checks for optional files, and this
# test checks that *adding* a previously non-existent file that was checked for triggers
# a rebuild of the custom fmt file

if(NOT DEFINED NEMATEX_EXE OR NOT DEFINED TEST_DIR OR NOT DEFINED PLAIN_FMT)
    message(FATAL_ERROR "NEMATEX_EXE, TEST_DIR, and PLAIN_FMT must be defined")
endif()

file(REMOVE_RECURSE "${TEST_DIR}")
file(MAKE_DIRECTORY "${TEST_DIR}")

set(DOC_FILE "${TEST_DIR}/probe_test.tex")
set(PROBE_FILE "${TEST_DIR}/optional_config.cfg")

file(REMOVE "${PROBE_FILE}")
file(WRITE "${DOC_FILE}" "\\newread\\cfgfile\n\\openin\\cfgfile=optional_config.cfg\n\\ifeof\\cfgfile\n  \\def\\probeval{NotFound}\n\\else\n  \\def\\probeval{Found}\n\\fi\n\\closein\\cfgfile\n\\checkpointformat\nProbe: \\probeval.\n\\bye\n")

# cold run while probe is absent
execute_process(
    COMMAND "${NEMATEX_EXE}" --fmt=${PLAIN_FMT} --auto-checkpoint probe_test.tex
    WORKING_DIRECTORY "${TEST_DIR}"
    RESULT_VARIABLE res1
    OUTPUT_VARIABLE out1
    ERROR_VARIABLE err1
)

if(NOT res1 EQUAL 0 OR NOT EXISTS "${TEST_DIR}/probe_test__nematex__checkpointed.fmt")
    message(FATAL_ERROR "Cold run failed: ${out1}\n${err1}")
endif()

file(SHA256 "${TEST_DIR}/probe_test.dvi" HASH_ABSENT)

# hot run while probe is still absent
execute_process(
    COMMAND "${NEMATEX_EXE}" --fmt=${PLAIN_FMT} --auto-checkpoint probe_test.tex
    WORKING_DIRECTORY "${TEST_DIR}"
    RESULT_VARIABLE res2
    OUTPUT_VARIABLE out2
    ERROR_VARIABLE err2
)

if(NOT res2 EQUAL 0)
    message(FATAL_ERROR "Hot run failed with code ${res2}: ${out2}\n${err2}")
endif()

if(NOT "${out2}" MATCHES "\\[checkpoint\\] resuming from format")
    message(FATAL_ERROR "Expected format resumption while probe is absent: ${out2}")
endif()

# create the optional file and run again
file(WRITE "${PROBE_FILE}" "% Optional config file now exists\n")

execute_process(
    COMMAND "${NEMATEX_EXE}" --fmt=${PLAIN_FMT} --auto-checkpoint probe_test.tex
    WORKING_DIRECTORY "${TEST_DIR}"
    RESULT_VARIABLE res3
    OUTPUT_VARIABLE out3
    ERROR_VARIABLE err3
)

if(NOT res3 EQUAL 0)
    message(FATAL_ERROR "Rebuild failed with code ${res3}: ${out3}\n${err3}")
endif()

if("${out3}" MATCHES "\\[checkpoint\\] resuming from format")
    message(FATAL_ERROR "Creating probe file should have triggered cold rebuild, but resumed from format!")
endif()

if(NOT "${out3}" MATCHES "\\[checkpoint\\] format written to")
    message(FATAL_ERROR "Expected cold rebuild notice: ${out3}")
endif()

file(SHA256 "${TEST_DIR}/probe_test.dvi" HASH_PRESENT)

if("${HASH_ABSENT}" STREQUAL "${HASH_PRESENT}")
    message(FATAL_ERROR "DVI output should have changed from NotFound to Found")
endif()
