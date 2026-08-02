include(${CMAKE_CURRENT_LIST_DIR}/../CompareHelpers.cmake)

setup_comparison()

normalize_banner()
normalize_command_line()
normalize_data_model()

# This test (running tex in extended mode on the original trip.tex file) was kind of annoying. I tried to create `patched_trip_log_etex_diffs.log`, which corresponds to the trip.log file but patched up according to the allowed differences described in the etripman.tex file and the many entries in the etrip.diffs file.

# I, apparently, did not do a very good job.
# Below is a list of additional normalizations (all related to Appendix A item 4f of the etripman), along with the etrip.diffs line each is targeted at.

# Justified by etrip.diffs:350
normalize_string("the \\fontdimen values needed in math extension fonts.\n\n{restoring \\displaywidth=0.0pt}\n{restoring \\predisplaysize=0.0pt}\n{restoring \\fam=0}" "the \\fontdimen values needed in math extension fonts.\n")

# Justified by etrip.diffs:352
normalize_string("{restoring \\predisplaypenalty=0}\n{restoring \\displayindent=0.0pt}\n{restoring \\displaywidth=0.0pt}\n{restoring \\predisplaysize=0.0pt}\n{restoring \\fam=0}" "{restoring \\predisplaypenalty=0}")

# Justified by etrip.diffs:368
normalize_string("{select font trip}\n{end-group character }}\n{restoring current font=\\ip}\n{restoring \\fam=-1}" "{select font trip}\n{restoring current font=\\ip}")

# Justified by etrip.diffs:370
normalize_string("{restoring \\penalty=\\penalty}\n{restoring \\displayindent=0.0pt}\n{restoring \\displaywidth=0.0pt}\n{restoring \\predisplaysize=0.0pt}\n{restoring \\fam=0}" "{restoring \\penalty=\\penalty}")

# Justified by etrip.diffs:370
normalize_string("{\\fam}\n{the character -}\n{end-group character }}\n{restoring \\fam=-1}" "{\\fam}\n{the character -}\n{end-group character }}")

# Justified by etrip.diffs:380
normalize_string("{true}\n{restoring \\displayindent=3.0pt}\n{restoring \\displaywidth=13.0pt}\n{restoring \\predisplaysize=24.0pt}" "{true}")

# Justified by etrip.diffs:382
normalize_string("{restoring \\catcode74=11}\n{restoring \\displayindent=0.0pt}\n{restoring \\displaywidth=0.0pt}\n{restoring \\predisplaysize=0.0pt}\n{restoring \\fam=0}" "{restoring \\catcode74=11}")

# Justified by etrip.diffs:396
normalize_string("So I shall assume that you typed `$$' both times.\n\n{restoring \\displayindent=0.0pt}\n{restoring \\displaywidth=0.0pt}\n{restoring \\predisplaysize=0.0pt}\n{restoring \\fam=0}" "So I shall assume that you typed `$$' both times.\n")

# Justified by etrip.diffs:409-412
normalize_regex("[ \t]+\n" "\n")

compare_and_report()
