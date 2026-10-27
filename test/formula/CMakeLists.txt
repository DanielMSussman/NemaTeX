set(MATH_TEST_SCRATCH_DIR "${CMAKE_BINARY_DIR}/math_tests")

function(add_math_test TEST_NAME SCRIPT_NAME)
    set(TEST_SCRATCH "${MATH_TEST_SCRATCH_DIR}/${TEST_NAME}")
    add_test(
        NAME ${TEST_NAME}
        COMMAND ${CMAKE_COMMAND}
            -DNEMATEX_EXE=$<TARGET_FILE:nematex>
            -DLATEX_FMT=${CMAKE_BINARY_DIR}/latex.fmt
            -DTEST_DIR=${TEST_SCRATCH}
            -P ${CMAKE_CURRENT_SOURCE_DIR}/${SCRIPT_NAME}
    )
endfunction()

add_math_test(LaTeX_OpenType_Math test_latex_math.cmake)
