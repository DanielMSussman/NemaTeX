# these tests generate and compare pageIR from the plain and ua2plain versions of the gentle/ua2gentle.tex files
setup_test_fixture(
    NAME Setup_GentlePhase3
    FIXTURE_NAME GentlePhase3Files
    ENVIRONMENT "NEMATEX_TRIP_TEST=1"
    ARGS "--null;--dump-page-ir=${NEMATEX_TEST_OUTPUT_DIR}/gentle_ir.txt;&plain gentle"
    OUT_FILE ${NEMATEX_TEST_OUTPUT_DIR}/gentle.fot
)

compare_output_test(PageIR_gentle gentle_ir.txt gentle_ir.txt ../CompareNonNormalizedFiles.cmake GentlePhase3Files)

setup_test_fixture(
    NAME Setup_UA2Gentle
    FIXTURE_NAME UA2GentleFiles
    ENVIRONMENT "NEMATEX_TRIP_TEST=1"
    ARGS "--null;--dump-page-ir=${NEMATEX_TEST_OUTPUT_DIR}/ua2gentle_ir.txt;--fmt=ua2plain;ua2gentle"
    OUT_FILE ${NEMATEX_TEST_OUTPUT_DIR}/ua2gentle.out
)

compare_output_test(PageIR_ua2gentle ua2gentle_ir.txt ua2gentle_ir.txt ../CompareNonNormalizedFiles.cmake UA2GentleFiles)

# other pageIR things
setup_test_fixture(
    NAME Setup_ImagesPageIR
    FIXTURE_NAME ImagesPageIRFiles
    ARGS "--null;--dump-page-ir=${NEMATEX_TEST_OUTPUT_DIR}/test_images_ir.txt;--fmt=plain;test_images"
    OUT_FILE ${NEMATEX_TEST_OUTPUT_DIR}/test_images.fot
)

compare_output_test(PageIR_images test_images_ir.txt test_images_ir.txt ../CompareNonNormalizedFiles.cmake ImagesPageIRFiles)
