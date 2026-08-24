# The (e)-trip test is set up as a conformance test that compares terminal
# output and log / dvi files to known golden files. The (e)tripman.tex file
# specifies the various deviations that are allowed when making this comparison.
#
# Our strategy will be to implement those permitted deviations by parsing the 
# files and using regexes to normalize both the gold and generated files, after
# which we can directly compare the two normalized files. Inspecting this file,
# thus, lets you directly see what we've done and judge for yourself whether we
# have actually complied with the test. Most of the replacements are
# unobjectionable, but there are perhaps a few edge cases.

# First, a few overall comments on the trip test (Appendix A of tripman)
# Item 1: We skip the PltoTF back-and-forth conversion, and just use the gold tfm file.
# Item 2: Note that we have changed the structure of the memory array. It is not possible to set `mem_min` and `mem_bot` to zero
# Item 3 (and other "run the code" steps): we are doing the equivalent, but there is no REPL mode so we just pass the input string to the program.


# Interpretation: It seems reasonable that the way the program announces itself should be allowed to be different. 
# This is just a hardcoded string in the engine, so it would be easy to change to match the gold files
macro(normalize_banner)
    normalize_regex("^This is (e-)?TeX, Version 3\\.141592653 \\(INITEX\\)[^\n]*" "BANNER_MOCKED")
    normalize_regex("^This is (e-)?TeX, Version 3\\.141592653[^\n]*" "BANNER_MOCKED")
    normalize_regex("^This is (e-)?TeX, Version [^\n]*(\n \\(INITEX\\))?[\n]+" "BANNER_MOCKED\n")
endmacro()

# Appendix A item 5a: The date and file name may be different
macro(normalize_preloaded_format_date)
    normalize_regex("\\(preloaded format=e?trip [^\n]*\\)" "(preloaded format=trip [date removed])")
endmacro()

# Appendix A item 5f: Number and length of strings may be different 
# Appendix A item 5g: memory usage statistics may change
# Appendix A item 5d: Values for stack size, buf size, etc, may be different
# Comment: What, exactly, does "etc" encompass? What counts as "memory usage" once we have played with the underlying memory model?
macro(normalize_data_model)
    normalize_regex("Memory usage before: [^\n]*" "Memory usage: [mocked]")
    normalize_regex("([0-9]+) words of memory out of ([0-9]+)" "[x] words of memory out of [y]")
    normalize_regex("([0-9]+) memory locations dumped; current usage is [^\n]*" "memory locations dumped: [mocked]")
    normalize_regex("Memory usage before: [0-9]+&[0-9]+; after: [0-9]+&[0-9]+; still untouched: [0-9]+" "Memory usage before: [X]&[X]; after: [X]&[X]; still untouched: [X]")
    normalize_regex("([0-9]+) strings of total length ([0-9]+)" "[X] strings of total length [Y]")
    normalize_regex("([0-9]+) strings out of ([0-9]+)" "[X] strings out of [Y]")
    normalize_regex("([0-9]+) string characters out of ([0-9]+)" "[X] string characters out of [Y]")
    normalize_regex("([0-9]+) multiletter control sequences out of ([0-9]+)(\\+[0-9]+)?" "[X] multiletter control sequences out of [Y]")
    normalize_regex("([0-9]+) multiletter control sequences[^\n]*" "[X] multiletter control sequences [mocked]")
    normalize_regex("[0-9]+i,[0-9]+n,[0-9]+p,[0-9]+b,[0-9]+s stack positions out of [^\n]*" "[x] stack positions [mocked]")
    normalize_regex("Hyphenation trie of length [0-9]+ has [0-9]+ ops out of [^\n]*" "Hyphenation trie of length [x] has [y] ops out of [z]")
    # hmm...
    normalize_regex("([0-9]+) words of font info for ([0-9]+) [^\n]*" "[x] words of font info [mocked]")
    normalize_regex("([0-9]+) words of font info for 4 fonts, out of ([0-9]+) for ([0-9]+)" "[x] words of font info [mocked]")
    normalize_regex("([0-9]+) words of font info for 3 preloaded fonts" "[x] words of font info [mocked]")
    normalize_regex("([0-9]+) hyphenation exceptions? out of [0-9]+" "[x] hyphenation exceptions out of [H]")
endmacro()

# Appendix A item 5b: Glue set values are subject to system-dependent rounding
# here is a list of the ones we needed to tinker with
macro(normalize_glue_set)
    normalize_regex("glue set 1166\\.9285[0-9]" "glue set 1166.9285X")
    normalize_regex("glue set 163[45]\\.[0-9]+" "glue set 163X.XX")
endmacro()


macro(normalize_command_line)
    normalize_regex("\\*\\*\\*?[^\n]*" "**[command line mocked]")
    normalize_regex("^\\*\\*[ \t]*(&e?trip[ \t]+trip)?[ \t]*[\n]*" "**[command line mocked]\n")
endmacro()

# You should probably be suspicious of the following
macro(strip_tex82_errors)
    # We have unconditionally expanded how we read characters and math characters to allow (math)char codes beyond the original. 
    # We could gate this behind an extended mode, but haven't
    normalize_regex("! Bad character code \\(256\\)\\.[\n]+<to be read again> [\n]+ *- *[\n]+l\\.26[^\n]*[\n]+[^\n]*mathchardef[^\n]*[\n]+A character number must be between 0 and 255\\.[\n]+I changed this one to zero\\.[\n]+" "")
    normalize_regex("! Bad mathchar \\(32768\\)\\.[\n]+<to be read again> [\n]+ *\\\\def [\n]+l\\.26 \\.\\.\\.\\\\mathchardef\\\\a=\"8000\\\\def[\n]+ *\\\\a\\{ SCALED 3~2769\\}[\n]+A mathchar number must be between 0 and 32767\\.[\n]+I changed this one to zero\\.[\n]+" "")

    # We have unconditionally changed the number of registers... we could gate this behind extended mode (as e-tex does), but so far we haven't
    normalize_string("{\\toks256}" "{\\toks0}")
    normalize_regex("! Bad register code \\(256\\)\\.[\n]+l\\.29 \\.\\.\\.\\{1\\} \\\\toksdef\\\\tokens=256 [\n]+ *\\\\show\\\\errorstopmode[\n]+A register number must be between 0 and 255\\.[\n]+I changed this one to zero\\.[\n]+" "")
endmacro()

macro(normalize_unicode_character_ranges)
    normalize_regex("A character number must be between 0 and 1114111\\." "A character number must be between 0 and 255.")
    normalize_regex("! Bad character code \\(256\\)\\.[\n]+l\\.676[^\n]*[\n]+[^\n]*[\n]+A character number must be between 0 and 255\\.[\n]+I changed this one to zero\\.[\n]+" "")
    normalize_regex("A mathchar number must be between 0 and (2097151|2\\^31-1)\\." "A mathchar number must be between 0 and 32767.")
    normalize_regex("! Bad mathchar \\(32768\\)\\.[\n]+<to be read again> [\n]+ *\\\\mathchardef [\n]+(\\.\\.\\.[\n]+)?l\\.1024[^\n]*[\n]+[^\n]*[\n]+A mathchar number must be between 0 and 32767\\.[\n]+I changed this one to zero\\.[\n]+" "")
endmacro()
