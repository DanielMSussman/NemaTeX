add_compile_options(
    $<$<CXX_COMPILER_ID:MSVC>:/UNDEBUG>
    $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-UNDEBUG>
)

add_executable(test_unicode_utils test_unicode_utils.cpp)

target_include_directories(test_unicode_utils PRIVATE
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/src/utility
)

target_link_libraries(test_unicode_utils PRIVATE
    Utils
    nematex_compile_options
)

add_test(NAME Test_UnicodeUtils COMMAND test_unicode_utils)

setup_test_fixture(
    NAME Setup_Unicode_MixedInput
    FIXTURE_NAME Unicode_MixedInput_Files
    ENVIRONMENT "NEMATEX_TRIP_TEST=1"
    ARGS "--null;--fmt=ua2plain;unicode_mixed_input"
    OUT_FILE ${NEMATEX_TEST_OUTPUT_DIR}/unicode_mixed_input.fot
    MOVE_SRC unicode_mixed_input.log
    MOVE_DST ${NEMATEX_TEST_OUTPUT_DIR}/unicode_mixed_input.log
)

compare_output_test(
    Unicode_MixedInput
    unicode_mixed_input.log
    unicode_mixed_input.log
    "${PROJECT_SOURCE_DIR}/test/ComparePrimitiveLog.cmake"
    Unicode_MixedInput_Files
)

setup_test_fixture(
    NAME Setup_Unicode_Hyphenation
    FIXTURE_NAME Unicode_Hyphenation_Files
    ENVIRONMENT "NEMATEX_TRIP_TEST=1"
    ARGS "--null;--fmt=ua2plain;unicode_hyphenatation_test"
    OUT_FILE ${NEMATEX_TEST_OUTPUT_DIR}/unicode_hyphenatation_test.fot
    MOVE_SRC unicode_hyphenatation_test.log
    MOVE_DST ${NEMATEX_TEST_OUTPUT_DIR}/unicode_hyphenatation_test.log
)

compare_output_test(
    Unicode_Hyphenation
    unicode_hyphenatation_test.log
    unicode_hyphenatation_test.log
    "${PROJECT_SOURCE_DIR}/test/ComparePrimitiveLog.cmake"
    Unicode_Hyphenation_Files
)
