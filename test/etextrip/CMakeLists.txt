setup_test_fixture(
    NAME Setup_ETripPhase1
    FIXTURE_NAME ETripPhase1Files
    ARGS "*\\input;trip"
    OUT_FILE ${CMAKE_BINARY_DIR}/test_output/redirect_etrip_output.txt
    MOVE_SRC trip.log
    MOVE_DST ${CMAKE_BINARY_DIR}/test_output/etrip_phase1.log
)
compare_output_test(CompareETripPhase1 etrip_phase1.log ../triptest/tripin.log CompareEtexLogPhase1.cmake ETripPhase1Files)

setup_test_fixture(
    NAME Setup_ETripPhase2
    FIXTURE_NAME ETripPhase2Files
    REQUIRES ETripPhase1Files
    ARGS "--dump-page-ir=${CMAKE_BINARY_DIR}/test_output/etrip_ir.txt; &trip \\toksdef\\tokens=0 \\input trip"
    OUT_FILE ${CMAKE_BINARY_DIR}/test_output/etrip.fot
    MOVE_SRC trip.log
    MOVE_DST ${CMAKE_BINARY_DIR}/test_output/etrip_phase2.log
)
compare_output_test(CompareETripPhase2Log etrip_phase2.log patched_trip_log_etex_diffs.log CompareEtexLogPhase2.cmake ETripPhase2Files)

setup_test_fixture(
    NAME Setup_ETripPhase3
    FIXTURE_NAME ETripPhase3Files
    REQUIRES ETripPhase2Files
    ARGS "*etrip"
    OUT_FILE ${CMAKE_BINARY_DIR}/test_output/redirect_etrip_phase3_output.txt
    MOVE_SRC etrip.log
    MOVE_DST ${CMAKE_BINARY_DIR}/test_output/etrip_phase3.log
)
compare_output_test(CompareETripPhase3 etrip_phase3.log etripin.log CompareEtexLogPhase3.cmake ETripPhase3Files)

setup_test_fixture(
    NAME Setup_ETripPhase4
    FIXTURE_NAME ETripPhase4Files
    REQUIRES ETripPhase3Files
    ENVIRONMENT "NEMATEX_TRIP_TEST=1"
    IGNORE_FAIL
    ARGS "&etrip etrip"
    INPUT_FILE ${CMAKE_BINARY_DIR}/empty_input.txt
    OUT_FILE ${CMAKE_BINARY_DIR}/test_output/etrip_final.fot
    MOVE_SRC etrip.log
    MOVE_DST ${CMAKE_BINARY_DIR}/test_output/etrip.log
    MOVE_SRC2 etrip.dvi
    MOVE_DST2 ${CMAKE_BINARY_DIR}/test_output/etrip.dvi
)
compare_output_test(CompareETripPhase4Log etrip.log etrip.log CompareEtexLogPhase4.cmake ETripPhase4Files)

compare_output_test(CompareETripPhase4Fot etrip_final.fot etrip.fot CompareETripFot.cmake ETripPhase4Files)

add_test(
    NAME CompareETripDVI
    COMMAND ${CMAKE_COMMAND}
        -DDVITYPE_EXECUTABLE=${DVITYPE_EXECUTABLE}
        -DGENERATED_DVI=${CMAKE_BINARY_DIR}/test_output/etrip.dvi
        -DGOLD_TYP=${CMAKE_CURRENT_SOURCE_DIR}/etrip.typ
        -DTMP_DIR=${CMAKE_BINARY_DIR}/Testing/Temporary
        -P ${CMAKE_CURRENT_SOURCE_DIR}/CompareETripTyp.cmake
)
set_tests_properties(CompareETripDVI PROPERTIES FIXTURES_REQUIRED ETripPhase4Files)

