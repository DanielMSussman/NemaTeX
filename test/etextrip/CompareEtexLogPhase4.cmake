include(${CMAKE_CURRENT_LIST_DIR}/../CompareHelpers.cmake)

setup_comparison()

normalize_banner()
normalize_preloaded_format_date()
normalize_regex("\\*\\*\\*?" "**")
normalize_data_model()
normalize_glue_set()
normalize_excess_newlines()

normalize_regex("[ ]*\\((\\./)?e?trip\\.tex( ##)?" "(trip.tex")

compare_and_report()
