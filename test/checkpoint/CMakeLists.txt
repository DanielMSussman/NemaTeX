set(CHECKPOINT_SCRATCH_DIR "${CMAKE_BINARY_DIR}/checkpoint_tests")

function(add_checkpoint_test TEST_NAME SCRIPT_NAME)
    set(TEST_SCRATCH "${CHECKPOINT_SCRATCH_DIR}/${TEST_NAME}")
    add_test(
        NAME ${TEST_NAME}
        COMMAND ${CMAKE_COMMAND}
            -DNEMATEX_EXE=$<TARGET_FILE:nematex>
            -DPLAIN_FMT=${CMAKE_BINARY_DIR}/plain.fmt
            -DLATEX_FMT=${CMAKE_BINARY_DIR}/latex.fmt
            -DTEST_DIR=${TEST_SCRATCH}
            -P ${CMAKE_CURRENT_SOURCE_DIR}/${SCRIPT_NAME}
    )
endfunction()

# Please forgive my horrible cmake inside these files... yikes
add_checkpoint_test(Checkpoint_parity test_parity.cmake)
add_checkpoint_test(Checkpoint_body_edit test_body_edit.cmake)
add_checkpoint_test(Checkpoint_invalidate_preamble test_preamble_invalidation.cmake)
add_checkpoint_test(Checkpoint_invalidate_local_dep test_local_dep_invalidation.cmake)
add_checkpoint_test(Checkpoint_invalidate_local_negative_probe test_negative_probe.cmake)
add_checkpoint_test(Checkpoint_fail_invariants test_invariant_fallback.cmake)
add_checkpoint_test(Checkpoint_diagnostic_warnings test_error_diagnostics.cmake)
