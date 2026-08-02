include(${CMAKE_CURRENT_LIST_DIR}/../CompareHelpers.cmake)

setup_comparison()

normalize_banner()
normalize_preloaded_format_date()
normalize_regex("entering extended mode\n" "")
normalize_regex("\\*\\*\\*" "**")
normalize_data_model()
strip_tex82_errors()

compare_and_report()
