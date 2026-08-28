function(add_l3primitive_test TEST_NAME BASE_NAME)
    setup_test_fixture(
        NAME Setup_L3Primitives_${TEST_NAME}
        FIXTURE_NAME L3_${TEST_NAME}_Files
        IGNORE_FAIL
        ARGS "--null;--fmt=plain;${BASE_NAME}"
        OUT_FILE ${NEMATEX_TEST_OUTPUT_DIR}/${BASE_NAME}.fot
        MOVE_SRC ${BASE_NAME}.log
        MOVE_DST ${NEMATEX_TEST_OUTPUT_DIR}/${BASE_NAME}.log
    )

    compare_output_test(
        L3Primitives_${TEST_NAME}
        ${BASE_NAME}.log
        ${BASE_NAME}.log
        ComparePrimitiveLog.cmake
        L3_${TEST_NAME}_Files
    )
endfunction()

add_l3primitive_test(Expanded expanded)
add_l3primitive_test(Ifincsname ifincsname)
add_l3primitive_test(Strcmp strcmp)
add_l3primitive_test(RNG rng)
add_l3primitive_test(FileOps fileops)
add_l3primitive_test(PDFPrimitive pdfprimitive)
add_l3primitive_test(Misc misc)
add_l3primitive_test(Unicode unicode)
