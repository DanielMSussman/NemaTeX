# Helper function for registering primitive output comparison tests across suites (e.g. L3, NewPrimitives)

function(add_primitive_test TEST_NAME BASE_NAME SUITE_NAME)
    if(SUITE_NAME STREQUAL "L3" OR SUITE_NAME STREQUAL "L3Primitives")
        set(SUITE_PREFIX "L3Primitives")
        set(FIXTURE_PREFIX "L3")
    else()
        set(SUITE_PREFIX "${SUITE_NAME}")
        set(FIXTURE_PREFIX "${SUITE_NAME}")
    endif()

    setup_test_fixture(
        NAME Setup_${SUITE_PREFIX}_${TEST_NAME}
        FIXTURE_NAME ${FIXTURE_PREFIX}_${TEST_NAME}_Files
        IGNORE_FAIL
        ARGS "--null;--fmt=plain;${BASE_NAME}"
        OUT_FILE ${NEMATEX_TEST_OUTPUT_DIR}/${BASE_NAME}.fot
        MOVE_SRC ${BASE_NAME}.log
        MOVE_DST ${NEMATEX_TEST_OUTPUT_DIR}/${BASE_NAME}.log
    )

    compare_output_test(
        ${SUITE_PREFIX}_${TEST_NAME}
        ${BASE_NAME}.log
        ${BASE_NAME}.log
        "${PROJECT_SOURCE_DIR}/test/ComparePrimitiveLog.cmake"
        ${FIXTURE_PREFIX}_${TEST_NAME}_Files
    )
endfunction()
