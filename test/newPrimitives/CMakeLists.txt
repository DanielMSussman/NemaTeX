#let assert statements remain active
add_compile_options(
    $<$<CXX_COMPILER_ID:MSVC>:/UNDEBUG>
    $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-UNDEBUG>
)

add_executable(test_float_evaluator test_float_evaluator.cpp)

target_include_directories(test_float_evaluator PRIVATE
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/src/math
)

target_link_libraries(test_float_evaluator PRIVATE
    Math
    nematex_compile_options
)

add_test(NAME Test_FloatEvaluator COMMAND test_float_evaluator)

add_executable(test_math_alphabets test_math_alphabets.cpp)
target_include_directories(test_math_alphabets PRIVATE
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/src/formula
)
target_link_libraries(test_math_alphabets PRIVATE
    Formula
    nematex_compile_options
)
add_test(NAME Test_MathAlphabets COMMAND test_math_alphabets)

add_primitive_test(FloatEval floateval NewPrimitives)
add_primitive_test(FloatEvalD floatevald NewPrimitives)
