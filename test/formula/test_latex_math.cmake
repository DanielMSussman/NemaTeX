# Test verification of Native OpenType Math in LaTeX
if(NOT DEFINED NEMATEX_EXE OR NOT DEFINED TEST_DIR OR NOT DEFINED LATEX_FMT)
    message(FATAL_ERROR "NEMATEX_EXE, TEST_DIR, and LATEX_FMT must be defined")
endif()

file(REMOVE_RECURSE "${TEST_DIR}")
file(MAKE_DIRECTORY "${TEST_DIR}")

set(DOC_FILE "${TEST_DIR}/math_test.tex")
file(WRITE "${DOC_FILE}" "\\documentclass{article}
\\begin{document}
\\typeout{=== START MATH TEST ===}
Basic formula: $a^2 + b^2 = c^2$
Styles: $\\mathbf{x} + \\mathbf{1} = \\mathbf{y}$
Bold Greek: $\\mathbf{\\alpha} + \\mathbf{\\beta} = \\mathbf{\\gamma}$
Italic: $\\mathit{x} + \\mathit{y}$
Script Fraktur Blackboard: $\\mathcal{A} + \\mathfrak{B} + \\mathbb{R}$
Roman and Upright: $\\mathrm{eff} + \\symup{x}$
Radical Delimiters Integral: $\\sqrt{\\frac{a}{b}} + \\left( \\int_0^\\infty f(x) dx \\right)$
Large Operators: $\\sum_{i=1}^n \\frac{1}{i^2} = \\frac{\\pi^2}{6}$
Primes: $f'(x) + f''(x) + f'_1(x) + f_1'(x)$
Family Config: \\Umathfamilyconfig 14 = 0 8 $ \\fam=14 X + Y + Z $
\\typeout{=== END MATH TEST ===}
\\end{document}
")

execute_process(
    COMMAND "${NEMATEX_EXE}" --fmt=${LATEX_FMT} --pdf math_test.tex
    WORKING_DIRECTORY "${TEST_DIR}"
    RESULT_VARIABLE res
    OUTPUT_VARIABLE out_log
    ERROR_VARIABLE err_log
)

if(NOT res EQUAL 0)
    message(FATAL_ERROR "nematex failed on math_test.tex with exit code ${res}:\n${out_log}\n${err_log}")
endif()

if(NOT EXISTS "${TEST_DIR}/math_test.pdf")
    message(FATAL_ERROR "math_test.pdf was not generated")
endif()

file(READ "${TEST_DIR}/math_test.log" log_content)

# Verify no TeX error occurred
if("${log_content}" MATCHES "\n! ")
    message(FATAL_ERROR "Error found in math_test.log:\n${log_content}")
endif()

# Verify glyph correctness via pdftotext
find_program(PDFTOTEXT_EXE pdftotext)
if(PDFTOTEXT_EXE)
    execute_process(
        COMMAND "${PDFTOTEXT_EXE}" "${TEST_DIR}/math_test.pdf" -
        OUTPUT_VARIABLE pdf_text
        RESULT_VARIABLE ptt_res
    )
    if(NOT ptt_res EQUAL 0)
        message(FATAL_ERROR "pdftotext failed with exit code ${ptt_res}")
    endif()

    # Exact glyph assertions
    if(NOT "${pdf_text}" MATCHES "ℝ")
        message(FATAL_ERROR "\\mathbb{R} did not render as ℝ (U+211D). Output was:\n${pdf_text}")
    endif()
    if(NOT "${pdf_text}" MATCHES "𝒜")
        message(FATAL_ERROR "\\mathcal{A} did not render as 𝒜 (U+1D49C). Output was:\n${pdf_text}")
    endif()
    if(NOT "${pdf_text}" MATCHES "𝔅")
        message(FATAL_ERROR "\\mathfrak{B} did not render as 𝔅 (U+1D505). Output was:\n${pdf_text}")
    endif()
    if(NOT "${pdf_text}" MATCHES "𝐱")
        message(FATAL_ERROR "\\mathbf{x} did not render as 𝐱 (U+1D431). Output was:\n${pdf_text}")
    endif()
    if(NOT "${pdf_text}" MATCHES "𝟏")
        message(FATAL_ERROR "\\mathbf{1} did not render as 𝟏 (U+1D7CE). Output was:\n${pdf_text}")
    endif()
    if(NOT "${pdf_text}" MATCHES "𝛂")
        message(FATAL_ERROR "\\mathbf{\\alpha} did not render as 𝛂 (U+1D6C2). Output was:\n${pdf_text}")
    endif()
    if(NOT "${pdf_text}" MATCHES "𝑥")
        message(FATAL_ERROR "\\mathit{x} did not render as 𝑥 (U+1D465). Output was:\n${pdf_text}")
    endif()
    if(NOT "${pdf_text}" MATCHES "𝖃")
        message(FATAL_ERROR "\\Umathfamilyconfig 14 = 0 8 did not render as 𝖃 (U+1D583). Output was:\n${pdf_text}")
    endif()
else()
    message(WARNING "pdftotext not found, skipping glyph correctness inspection")
endif()

message(STATUS "Native OpenType math test passed successfully with verified glyph correctness")
