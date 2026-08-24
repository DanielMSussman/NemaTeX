# For now, we're putting important output in a dedicated directory, and redirecting to an empty file in place of dev/null
set(NEMATEX_TEST_OUTPUT_DIR "${CMAKE_BINARY_DIR}/ctest_output")
file(MAKE_DIRECTORY ${NEMATEX_TEST_OUTPUT_DIR})
file(TOUCH ${CMAKE_BINARY_DIR}/empty_input.txt)

# Many of our tests are of the flavor "compare a generated file with a gold standard,
# with a cmake script that defines allowed differences between them"
function(compare_output_test TEST_NAME GENERATED_FILE GOLD_FILE SCRIPT_FILE REQUIRED_FIXTURE)
    add_test(
        NAME ${TEST_NAME}
        COMMAND ${CMAKE_COMMAND}
        -DGENERATED_FILE=${NEMATEX_TEST_OUTPUT_DIR}/${GENERATED_FILE}
            -DGOLD_FILE=${CMAKE_CURRENT_SOURCE_DIR}/${GOLD_FILE}
            -P ${CMAKE_CURRENT_SOURCE_DIR}/${SCRIPT_FILE}
    )
    set_tests_properties(${TEST_NAME} PROPERTIES 
        FIXTURES_REQUIRED ${REQUIRED_FIXTURE}
    )
endfunction()

# at some point I'll make this setup function nicer? But for now it's convenient
function(setup_test_fixture)
    cmake_parse_arguments(
        PARSE_ARGV 0 ARG 
        "IGNORE_FAIL"
        "NAME;FIXTURE_NAME;OUT_FILE;INPUT_FILE;MOVE_SRC;MOVE_DST;MOVE_SRC2;MOVE_DST2"
        "ARGS;REQUIRES;ENVIRONMENT"
    )
    set(cmd_args
        -DEXE=$<TARGET_FILE:${PROJECT_NAME}>
        "-DARGS=${ARG_ARGS}"
        -DWORK_DIR=${CMAKE_BINARY_DIR}
    )

    if(ARG_OUT_FILE)
        list(APPEND cmd_args -DOUT_FILE=${ARG_OUT_FILE})
    endif()
    if(ARG_INPUT_FILE)
        list(APPEND cmd_args -DINPUT_FILE=${ARG_INPUT_FILE})
    endif()
    if(ARG_IGNORE_FAIL)
        list(APPEND cmd_args -DIGNORE_FAIL=1)
    endif()
    if(ARG_MOVE_SRC AND ARG_MOVE_DST)
        list(APPEND cmd_args -DMOVE_SRC=${ARG_MOVE_SRC} -DMOVE_DST=${ARG_MOVE_DST})
    endif()
    if(ARG_MOVE_SRC2 AND ARG_MOVE_DST2)
        list(APPEND cmd_args -DMOVE_SRC2=${ARG_MOVE_SRC2} -DMOVE_DST2=${ARG_MOVE_DST2})
    endif()

    list(APPEND cmd_args -P ${PROJECT_SOURCE_DIR}/test/RunTestStep.cmake)

    add_test(
        NAME ${ARG_NAME}
        COMMAND ${CMAKE_COMMAND} ${cmd_args}
    )

    set_tests_properties(${ARG_NAME} PROPERTIES FIXTURES_SETUP "${ARG_FIXTURE_NAME}")
    
    if(ARG_REQUIRES)
        set_property(TEST ${ARG_NAME} APPEND PROPERTY FIXTURES_REQUIRED "${ARG_REQUIRES}")
    endif()
    if(ARG_ENVIRONMENT)
        set_property(TEST ${ARG_NAME} APPEND PROPERTY ENVIRONMENT "${ARG_ENVIRONMENT}")
    endif()
endfunction()

find_package(Python3 COMPONENTS Interpreter REQUIRED) #for some dvi comparisons, and inspecting tagged pdfs
find_program(DVITYPE_EXECUTABLE dvitype REQUIRED)

add_subdirectory(triptest)
add_subdirectory(etextrip)
add_subdirectory(pageir)
add_subdirectory(tagging)
add_subdirectory(l3primitives)
