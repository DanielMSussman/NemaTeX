if(CMAKE_BUILD_TYPE MATCHES Coverage)
    find_program(GCOVR_PATH gcovr)

    if(GCOVR_PATH)
        add_custom_target(coverage
            COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure

            COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/coverage_report

            COMMAND ${GCOVR_PATH} 
                --html-nested ${CMAKE_BINARY_DIR}/coverage_report/index.html
                --root ${CMAKE_SOURCE_DIR}
                --object-directory ${CMAKE_BINARY_DIR}
                --exclude "${CMAKE_SOURCE_DIR}/extern/.*"
                --exclude "${CMAKE_SOURCE_DIR}/test/.*"
                --print-summary
            
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS ${PROJECT_NAME} formats
            COMMENT "Generating HTML coverage report in ${CMAKE_BINARY_DIR}/coverage_report/index.html"
        )
    else()
        message(WARNING "gcovr not found! The 'coverage' target will not be available.")
    endif()
endif()
