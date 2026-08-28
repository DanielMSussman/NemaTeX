setup_test_fixture(
    NAME Setup_MathTagging
    FIXTURE_NAME MathTaggingFiles
    ARGS "math_tagging;-p;-c=0;--fmt=ua2plain"
    OUT_FILE ${NEMATEX_TEST_OUTPUT_DIR}/mathtagging.out
    MOVE_SRC math_tagging.pdf
    MOVE_DST ${NEMATEX_TEST_OUTPUT_DIR}/math_tagging.pdf
)

add_test(
    NAME Tagging_MathStructure
    COMMAND ${Python3_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/verify_math_tagging.py
            ${NEMATEX_TEST_OUTPUT_DIR}/math_tagging.pdf
            ${CMAKE_CURRENT_SOURCE_DIR}/reference_math_tagging.json
            ${NEMATEX_TEST_OUTPUT_DIR}/math_tagging_structure.out
)
set_tests_properties(Tagging_MathStructure PROPERTIES
    FIXTURES_REQUIRED MathTaggingFiles
)
