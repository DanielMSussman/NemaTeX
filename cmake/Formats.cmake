# We build some artifacts -- the fmt files -- alongside the main executable

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/plain.fmt
    COMMAND $<TARGET_FILE:${PROJECT_NAME}> " \\\\input plain \\\\dump" > /dev/null 2>&1
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    DEPENDS ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/assets/formats/plain.tex ${CMAKE_SOURCE_DIR}/assets/formats/hyphen.tex
    COMMENT "Generating plain.fmt..."
)
add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/ua2plain.fmt
    COMMAND $<TARGET_FILE:${PROJECT_NAME}> " \\\\input ua2plain \\\\dump" > /dev/null 2>&1
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    DEPENDS ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/assets/formats/ua2plain.tex ${CMAKE_SOURCE_DIR}/assets/formats/math-definitions.tex ${CMAKE_SOURCE_DIR}/assets/formats/hyphen.tex
    COMMENT "Generating ua2plain.fmt..."
)
add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/slides.fmt
    COMMAND $<TARGET_FILE:${PROJECT_NAME}> " \\\\input slides \\\\dump" > /dev/null 2>&1
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    DEPENDS ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/assets/formats/slides.tex ${CMAKE_BINARY_DIR}/ua2plain.fmt
    COMMENT "Generating slides.fmt..."
)
add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/latex.fmt
    COMMAND $<TARGET_FILE:${PROJECT_NAME}> " latex.ltx" > /dev/null 2>&1
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    DEPENDS ${PROJECT_NAME} 
    COMMENT "Generating latex.fmt..."
)



add_custom_target(formats ALL
    DEPENDS 
        ${CMAKE_BINARY_DIR}/plain.fmt 
        ${CMAKE_BINARY_DIR}/ua2plain.fmt
        ${CMAKE_BINARY_DIR}/slides.fmt
        ${CMAKE_BINARY_DIR}/latex.fmt
)
add_dependencies(formats ${PROJECT_NAME})
