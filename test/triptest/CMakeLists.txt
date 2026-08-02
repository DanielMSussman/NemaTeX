setup_test_fixture(
    NAME Setup_TripPhase1
    FIXTURE_NAME TripPhase1Files
    ENVIRONMENT "NEMATEX_TRIP_TEST=1"
    ARGS "\\input trip"
    OUT_FILE ${CMAKE_BINARY_DIR}/test_output/redirect_output.txt
    MOVE_SRC trip.log
    MOVE_DST ${CMAKE_BINARY_DIR}/test_output/trip_phase1.log
)

compare_output_test(CompareTripOutput trip_phase1.log tripin.log CompareOutput.cmake TripPhase1Files)

setup_test_fixture(
    NAME Setup_TripPhase2
    FIXTURE_NAME TripPhase2Files
    REQUIRES TripPhase1Files
    ENVIRONMENT "NEMATEX_TRIP_TEST=1"
    ARGS "--dump-page-ir=${CMAKE_BINARY_DIR}/test_output/trip_ir.txt; &trip  trip"
    OUT_FILE ${CMAKE_BINARY_DIR}/test_output/trip.fot
    MOVE_SRC trip.log
    MOVE_DST ${CMAKE_BINARY_DIR}/test_output/trip.log
    MOVE_SRC2 trip.dvi
    MOVE_DST2 ${CMAKE_BINARY_DIR}/test_output/trip.dvi
)

compare_output_test(CompareTripLog    trip.log    trip.log    CompareLogs.cmake    TripPhase2Files)
compare_output_test(CompareTripFot    trip.fot    trip.fot    CompareFot.cmake     TripPhase2Files)
compare_output_test(CompareTripPageIR trip_ir.txt trip_ir.txt ../CompareNonNormalizedFiles.cmake TripPhase2Files)

add_test(
    NAME CompareTripDVI
    COMMAND ${Python3_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/byte_compare_files.py
    ${CMAKE_BINARY_DIR}/test_output/trip.dvi
    ${CMAKE_CURRENT_SOURCE_DIR}/trip.dvi
)
set_tests_properties(CompareTripDVI PROPERTIES FIXTURES_REQUIRED TripPhase2Files)
