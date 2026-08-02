include(${CMAKE_CURRENT_LIST_DIR}/../CompareHelpers.cmake)

setup_comparison()

normalize_banner()
normalize_regex("\\(\\./etrip\\.tex" "(etrip.tex")
normalize_data_model()
normalize_regex("[\n]+$" "\n")
normalize_command_line()

compare_and_report()
