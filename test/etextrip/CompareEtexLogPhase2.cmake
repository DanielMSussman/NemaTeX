include(${CMAKE_CURRENT_LIST_DIR}/../CompareHelpers.cmake)

setup_comparison()

normalize_banner()
normalize_command_line()
normalize_data_model()

# Trailing whitespace
normalize_regex("[ \t]+\n" "\n")

compare_and_report()
