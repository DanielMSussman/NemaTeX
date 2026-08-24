include(${CMAKE_CURRENT_LIST_DIR}/../CompareHelpers.cmake)

setup_comparison()

normalize_banner()
normalize_preloaded_format_date()
normalize_regex("\\*\\*\\*?" "**")
normalize_data_model()
normalize_glue_set()

normalize_regex("[ ]*\\((\\./)?e?trip\\.tex" "(trip.tex")
normalize_regex("[ ]*\\((\\./)?e?trip\\.out" "(etrip.out")

normalize_unicode_character_ranges()

compare_and_report()
