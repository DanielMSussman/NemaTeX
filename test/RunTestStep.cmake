set(EXEC_ARGS COMMAND ${EXE} ${ARGS})

if(INPUT_FILE)
    list(APPEND EXEC_ARGS INPUT_FILE "${INPUT_FILE}")
endif()

execute_process(
    ${EXEC_ARGS}
    WORKING_DIRECTORY "${WORK_DIR}"
    OUTPUT_FILE "${OUT_FILE}"
    RESULT_VARIABLE exit_code
)

if(NOT exit_code EQUAL 0 AND NOT IGNORE_FAIL)
    message(FATAL_ERROR "Command failed with code: ${exit_code}")
endif()

if(COPY_SRC AND COPY_DST)
    if(EXISTS "${WORK_DIR}/${COPY_SRC}")
        file(COPY_FILE "${WORK_DIR}/${COPY_SRC}" "${COPY_DST}")
    endif()
endif()

if(MOVE_SRC AND MOVE_DST)
    if(EXISTS "${WORK_DIR}/${MOVE_SRC}")
        file(RENAME "${WORK_DIR}/${MOVE_SRC}" "${MOVE_DST}")
    endif()
endif()

# if this isn't a sign that this file is janky...
if(MOVE_SRC2 AND MOVE_DST2)
    if(EXISTS "${WORK_DIR}/${MOVE_SRC2}")
        file(RENAME "${WORK_DIR}/${MOVE_SRC2}" "${MOVE_DST2}")
    endif()
endif()
