setup_test_fixture(
    NAME Setup_TripPhase1
    FIXTURE_NAME TripPhase1Files
    ENVIRONMENT "NEMATEX_TRIP_TEST=1"
    ARGS "\\input trip"
    OUT_FILE ${NEMATEX_TEST_OUTPUT_DIR}/redirect_output.txt
    MOVE_SRC trip.log
    MOVE_DST ${NEMATEX_TEST_OUTPUT_DIR}/trip_phase1.log
)

compare_output_test(TripPhase1_log trip_phase1.log tripin.log CompareOutput.cmake TripPhase1Files)

setup_test_fixture(
    NAME Setup_TripPhase2
    FIXTURE_NAME TripPhase2Files
    REQUIRES TripPhase1Files
    ENVIRONMENT "NEMATEX_TRIP_TEST=1"
    ARGS "--dump-page-ir=${NEMATEX_TEST_OUTPUT_DIR}/trip_ir.txt; &trip  trip"
    OUT_FILE ${NEMATEX_TEST_OUTPUT_DIR}/trip.fot
    MOVE_SRC trip.log
    MOVE_DST ${NEMATEX_TEST_OUTPUT_DIR}/trip.log
    MOVE_SRC2 trip.dvi
    MOVE_DST2 ${NEMATEX_TEST_OUTPUT_DIR}/trip.dvi
)

compare_output_test(TripPhase2_log    trip.log    trip.log    CompareLogs.cmake    TripPhase2Files)
compare_output_test(TripPhase2_fot    trip.fot    trip.fot    CompareFot.cmake     TripPhase2Files)
compare_output_test(TripPhase2_pageIR trip_ir.txt trip_ir.txt ../CompareNonNormalizedFiles.cmake TripPhase2Files)

add_test(
    NAME TripPhase2_dvi
    COMMAND ${Python3_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/byte_compare_files.py
    ${NEMATEX_TEST_OUTPUT_DIR}/trip.dvi
    ${CMAKE_CURRENT_SOURCE_DIR}/trip.dvi
)
set_tests_properties(TripPhase2_dvi PROPERTIES FIXTURES_REQUIRED TripPhase2Files)
