set(ASSET_INDEX_HEADER "${CMAKE_SOURCE_DIR}/src/utility/asset_file_index.h")

file(GLOB_RECURSE ASSET_INDEX_INPUTS CONFIGURE_DEPENDS
    "${CMAKE_SOURCE_DIR}/assets/*"
    "${CMAKE_SOURCE_DIR}/test/*"
)

add_custom_command(
    OUTPUT "${ASSET_INDEX_HEADER}"
    COMMAND ${Python3_EXECUTABLE} "${CMAKE_SOURCE_DIR}/scripts/generate_asset_index.py"
            "${CMAKE_SOURCE_DIR}"
            "${ASSET_INDEX_HEADER}"
    DEPENDS "${CMAKE_SOURCE_DIR}/scripts/generate_asset_index.py"
            ${ASSET_INDEX_INPUTS}
    COMMENT "Generating asset file index header..."
)

add_custom_target(generate_asset_index
    DEPENDS "${ASSET_INDEX_HEADER}"
)
