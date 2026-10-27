#include "math/float_evaluator.h"

#include <cmath>
#include <string_view>

static bool g_failed = false;

#define ASSERT_TRUE(cond)                              \
    do                                                 \
        {                                              \
        if (!(cond))                                   \
            g_failed = true;                           \
        } while (0)

#define ASSERT_NEAR(val, expected, eps)                \
    do                                                 \
        {                                              \
        if (std::abs((val) - (expected)) > (eps))      \
            g_failed = true;                           \
        } while (0)

#define ASSERT_STR_EQ(val, expected)                   \
    do                                                 \
        {                                              \
        if ((val) != (expected))                       \
            g_failed = true;                           \
        } while (0)

void test_associativity_and_precedence(FloatEvaluator& eval)
    {
    ASSERT_NEAR(eval.evaluate("8 - 4 - 2").num_val, 2.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("16 / 4 / 2").num_val, 2.0, 1e-9);

    ASSERT_NEAR(eval.evaluate("2 ^ 3 ^ 2").num_val, 512.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("0 ? 1 : 1 ? 20 : 30").num_val, 20.0, 1e-9);

    ASSERT_NEAR(eval.evaluate("2pi^2").num_val, 2.0 * std::pow(3.141592653589793, 2.0), 1e-9);
    ASSERT_NEAR(eval.evaluate("-2^2").num_val, -4.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("(-2)^2").num_val, 4.0, 1e-9);

    ASSERT_NEAR(eval.evaluate("- - 5").num_val, 5.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("! !42").num_val, 1.0, 1e-9);

    eval.clear_error();
    eval.evaluate("2 3");
    ASSERT_TRUE(eval.has_error());

    eval.clear_error();
    eval.evaluate("-2 3");
    ASSERT_TRUE(eval.has_error());

    eval.clear_error();
    ParseValue pv = eval.evaluate("(1 + 2)3");
    ASSERT_TRUE(!eval.has_error());
    ASSERT_NEAR(pv.num_val, 9.0, 1e-9);

    ASSERT_NEAR(eval.evaluate("2(3 + 4)").num_val, 14.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("(1 + 2)(3 + 4)").num_val, 21.0, 1e-9);

    ASSERT_NEAR(eval.evaluate("2 ^ -2").num_val, 0.25, 1e-9);
    ASSERT_NEAR(eval.evaluate("2 ^ - 2 ^ 2").num_val, 0.0625, 1e-9);
    ASSERT_NEAR(eval.evaluate("-2 ^ -2").num_val, -0.25, 1e-9);
    ASSERT_NEAR(eval.evaluate("1 ? 2 + 3 : 4 * 5").num_val, 5.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("0 ? 2 + 3 : 4 * 5").num_val, 20.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("1 ? 0 ? 10 : 20 : 30").num_val, 20.0, 1e-9);
    }

void test_subtraction_vs_multiplication(FloatEvaluator& eval)
    {
    ASSERT_NEAR(eval.evaluate("2 - 3").num_val, -1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("2(-3)").num_val, -6.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("2pi").num_val, 2.0 * 3.141592653589793, 1e-9);
    ASSERT_NEAR(eval.evaluate("2e - 4").num_val, (2.0 * 2.718281828459045) - 4.0, 1e-9);
    }

void test_implicit_multiplication(FloatEvaluator& eval)
    {
    constexpr double pi = 3.141592653589793;
    constexpr double e = 2.718281828459045;

    ASSERT_NEAR(eval.evaluate("1 / 2pi").num_val, 1.0 / (2.0 * pi), 1e-9);
    ASSERT_NEAR(eval.evaluate("1 / 2*pi").num_val, (1.0 / 2.0) * pi, 1e-9);
    ASSERT_NEAR(eval.evaluate("1 / 2e").num_val, 1.0 / (2.0 * e), 1e-9);
    ASSERT_NEAR(eval.evaluate("1 / 2exp(1)").num_val, 1.0 / (2.0 * std::exp(1.0)), 1e-9);
    ASSERT_NEAR(eval.evaluate("1 / 2sin(pi/6)").num_val, 1.0 / (2.0 * std::sin(pi / 6.0)), 1e-9);
    ASSERT_NEAR(eval.evaluate("1 / 2*sin(pi/6)").num_val, (1.0 / 2.0) * std::sin(pi / 6.0), 1e-9);

    ASSERT_NEAR(eval.evaluate("1 / 2(3)").num_val, (1.0 / 2.0) * 3.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("1 / 2(pi)").num_val, (1.0 / 2.0) * pi, 1e-9);
    ASSERT_NEAR(eval.evaluate("1 / (1 + 2)pi").num_val, (1.0 / 3.0) * pi, 1e-9);
    ASSERT_NEAR(eval.evaluate("1 / sin(pi/6)pi").num_val, (1.0 / std::sin(pi / 6.0)) * pi, 1e-9);
    ASSERT_NEAR(eval.evaluate("(1 + 2)(3 + 4)").num_val, 21.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("2(3)(4)").num_val, 24.0, 1e-9);

    ASSERT_NEAR(eval.evaluate("2^3pi").num_val, 8.0 * pi, 1e-9);
    ASSERT_NEAR(eval.evaluate("2pi^3").num_val, 2.0 * std::pow(pi, 3.0), 1e-9);
    ASSERT_NEAR(eval.evaluate("(2pi)^3").num_val, std::pow(2.0 * pi, 3.0), 1e-9);

    eval.clear_error();
    eval.evaluate("2 3");
    ASSERT_TRUE(eval.has_error());

    eval.clear_error();
    eval.evaluate("-2 3");
    ASSERT_TRUE(eval.has_error());

    eval.clear_error();
    eval.evaluate("(1 + 2) 3 4");
    ASSERT_TRUE(eval.has_error());
    }

void test_scientific_notation_and_units(FloatEvaluator& eval)
    {
    ASSERT_NEAR(eval.evaluate("2e-4").num_val, 0.0002, 1e-9);
    ASSERT_NEAR(eval.evaluate("2e").num_val, 2.0 * 2.718281828459045, 1e-9);
    ASSERT_NEAR(eval.evaluate("2exp(3)").num_val, 2.0 * std::exp(3.0), 1e-9);
    ASSERT_NEAR(eval.evaluate("1cm / 1mm").num_val, 10.0, 1e-9);
    }

void test_trigonometry_and_angles(FloatEvaluator& rad_eval, FloatEvaluator& deg_eval)
    {
    ASSERT_NEAR(rad_eval.evaluate("sin(90deg)").num_val, 1.0, 1e-9);
    ASSERT_NEAR(deg_eval.evaluate("sin(90deg)").num_val, 1.0, 1e-9);
    ASSERT_NEAR(rad_eval.evaluate("sin(pi rad)").num_val, 0.0, 1e-9);
    ASSERT_NEAR(deg_eval.evaluate("sin(pi rad)").num_val, 0.0, 1e-9);

    ASSERT_STR_EQ(rad_eval.evaluate_to_string("sin(pi)"), "0");

    ASSERT_NEAR(deg_eval.evaluate("sin(90)").num_val, 1.0, 1e-9);
    ASSERT_NEAR(deg_eval.evaluate("asin(1.0)").num_val, 90.0, 1e-9);
    ASSERT_NEAR(deg_eval.evaluate("atan2(1, 1)").num_val, 45.0, 1e-9);

    ASSERT_NEAR(deg_eval.evaluate("sec(60)").num_val, 2.0, 1e-9);
    ASSERT_NEAR(deg_eval.evaluate("cosec(30)").num_val, 2.0, 1e-9);
    ASSERT_NEAR(deg_eval.evaluate("csc(30)").num_val, 2.0, 1e-9);
    ASSERT_NEAR(deg_eval.evaluate("cot(45)").num_val, 1.0, 1e-9);

    ASSERT_NEAR(rad_eval.evaluate("secd(60)").num_val, 2.0, 1e-9);
    ASSERT_NEAR(rad_eval.evaluate("cosecd(30)").num_val, 2.0, 1e-9);
    ASSERT_NEAR(rad_eval.evaluate("cotd(45)").num_val, 1.0, 1e-9);

    constexpr double PI_VAL = 3.14159265358979323846;
    ASSERT_NEAR(deg_eval.evaluate("radians(180)").num_val, 180.0, 1e-9);
    ASSERT_NEAR(rad_eval.evaluate("radians(180)").num_val, PI_VAL, 1e-9);
    ASSERT_NEAR(deg_eval.evaluate("deg(pi)").num_val, 180.0, 1e-9);
    ASSERT_NEAR(rad_eval.evaluate("deg(pi)").num_val, PI_VAL, 1e-9);
    }

void test_vector_and_scalar_geometry(FloatEvaluator& eval)
    {
    ASSERT_NEAR(eval.evaluate("veclen(12, 5)").num_val, 13.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("veclen(3, 4)").num_val, 5.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("scalar(10pt)").num_val, 10.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("scalar(28.45274pt)").num_val, 28.45274, 1e-9);
    ASSERT_NEAR(eval.evaluate("scalar(42)").num_val, 42.0, 1e-9);
    }

void test_modulo_operations(FloatEvaluator& eval)
    {
    ASSERT_NEAR(eval.evaluate("10 mod 3").num_val, 1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("mod(10, 3)").num_val, 1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("mod(-1, 4)").num_val, -1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("-1 mod 4").num_val, -1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("Mod(-1, 4)").num_val, 3.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("-1 Mod 4").num_val, 3.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("10 Mod 3").num_val, 1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("Mod(-10, -3)").num_val, -1.0, 1e-9);
    }

void test_bitwise_operations(FloatEvaluator& eval)
    {
    ASSERT_NEAR(eval.evaluate("5 & 3").num_val, 1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("5 | 2").num_val, 7.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("~0").num_val, -1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("1 << 4").num_val, 16.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("16 >> 2").num_val, 4.0, 1e-9);

    ASSERT_NEAR(eval.evaluate("bitand(5, 3)").num_val, 1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("bitor(5, 2)").num_val, 7.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("bitxor(5, 3)").num_val, 6.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("bitnot(0)").num_val, -1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("shiftleft(1, 4)").num_val, 16.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("shiftright(16, 2)").num_val, 4.0, 1e-9);

    ASSERT_NEAR(eval.evaluate("1 | 2 & 2").num_val, 3.0, 1e-9);
    }

void test_number_theory(FloatEvaluator& eval)
    {
    ASSERT_NEAR(eval.evaluate("gcd(42, 56)").num_val, 14.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("gcd(17, 19)").num_val, 1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("isprime(31)").num_val, 1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("isprime(64)").num_val, 0.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("isprime(1)").num_val, 0.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("isprime(2)").num_val, 1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("isodd(3)").num_val, 1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("isodd(4)").num_val, 0.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("iseven(4)").num_val, 1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("iseven(3)").num_val, 0.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("real(4)").num_val, 4.0, 1e-9);
    }

void test_relations_and_conditionals(FloatEvaluator& eval)
    {
    ASSERT_NEAR(eval.evaluate("4 = 4").num_val, 1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("4 == 5").num_val, 0.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("4 = 4 ? 10 : 20").num_val, 10.0, 1e-9);

    ASSERT_NEAR(eval.evaluate("notequal(2, 3)").num_val, 1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("notequal(3, 3)").num_val, 0.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("notgreater(2, 3)").num_val, 1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("notgreater(3, 2)").num_val, 0.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("notless(3, 2)").num_val, 1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("notless(2, 3)").num_val, 0.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("approxequalto(1.00005, 1.0)").num_val, 1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("approxequalto(1.0002, 1.0)").num_val, 0.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("ifthenelse(1, 42, 99)").num_val, 42.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("ifthenelse(0, 42, 99)").num_val, 99.0, 1e-9);
    }

void test_short_circuiting(FloatEvaluator& eval)
    {
    eval.clear_error();
    ParseValue pv1 = eval.evaluate("0 ? sqrt(-1) : 42");
    ASSERT_TRUE(!eval.has_error());
    ASSERT_NEAR(pv1.num_val, 42.0, 1e-9);

    eval.clear_error();
    ParseValue pv2 = eval.evaluate("1 || 1/0");
    ASSERT_TRUE(!eval.has_error());
    ASSERT_NEAR(pv2.num_val, 1.0, 1e-9);

    eval.clear_error();
    ParseValue pv3 = eval.evaluate("0 && 1/0");
    ASSERT_TRUE(!eval.has_error());
    ASSERT_NEAR(pv3.num_val, 0.0, 1e-9);
    }

void test_arrays_and_indexing(FloatEvaluator& eval)
    {
    ASSERT_NEAR(eval.evaluate("min(1, 2)").num_val, 1.0, 1e-9);

    ParseValue arr = eval.evaluate("{10, 20}");
    ASSERT_TRUE(arr.is_array());
    ASSERT_TRUE(arr.arr_val && arr.arr_val->size() == 2);

    ASSERT_NEAR(eval.evaluate("{10, 20, 30,}[2]").num_val, 30.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("{10, 20, 30}[1]").num_val, 20.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("{42}[0]").num_val, 42.0, 1e-9);

    ASSERT_NEAR(eval.evaluate("{{1, 2}, {3, 4}}[1][0]").num_val, 3.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("{{1, 2}, {3, 4}}[0][1]").num_val, 2.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("dim({10, 20, 30})").num_val, 3.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("dim({{1, 2}, {3, 4}})").num_val, 2.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("array({10, 20, 30}, 1)").num_val, 20.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("array({{1, 2}, {3, 4}}, 1)[0]").num_val, 3.0, 1e-9);
    }

void test_strings_and_formatting(FloatEvaluator& eval)
    {
    ParseValue pv = eval.evaluate("{\"north\", \"south\"}[0]");
    ASSERT_STR_EQ(pv.str_val, "north");

    ASSERT_NEAR(eval.evaluate("\"north\" == 'north'").num_val, 1.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("\"a\" != 'b'").num_val, 1.0, 1e-9);

    ASSERT_STR_EQ(eval.evaluate("bin(5)").str_val, "101");
    ASSERT_STR_EQ(eval.evaluate("bin(0)").str_val, "0");
    ASSERT_STR_EQ(eval.evaluate("oct(63)").str_val, "77");
    ASSERT_STR_EQ(eval.evaluate("hex(255)").str_val, "ff");
    ASSERT_STR_EQ(eval.evaluate("Hex(255)").str_val, "FF");
    ASSERT_STR_EQ(eval.evaluate("Hex(10)").str_val, "A");

    ASSERT_STR_EQ(eval.evaluate("strrepeat(3, \"ha\")").str_val, "hahaha");
    ASSERT_STR_EQ(eval.evaluate("strrepeat(0, 'ha')").str_val, "");

    ASSERT_NEAR(eval.evaluate("width(\"test\")").num_val, 24.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("height(\"test\")").num_val, 7.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("depth(\"test\")").num_val, 2.0, 1e-9);

    FloatEvaluator custom_eval;
    custom_eval.set_text_measure_callback(
        [](std::string_view text, int metric) -> double
        {
            if (metric == 1)
                return 10.0 * text.size();
            if (metric == 2)
                return 3.5;
            if (metric == 3)
                return 8.5;
            return 0.0;
        }
    );
    ASSERT_NEAR(custom_eval.evaluate("width(\"box\")").num_val, 30.0, 1e-9);
    ASSERT_NEAR(custom_eval.evaluate("depth(\"box\")").num_val, 3.5, 1e-9);
    ASSERT_NEAR(custom_eval.evaluate("height(\"box\")").num_val, 8.5, 1e-9);
    }

void test_math_helpers_and_aliases(FloatEvaluator& eval)
    {
    ASSERT_NEAR(eval.evaluate("div(7, 2)").num_val, 3.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("frac(3.75)").num_val, 0.75, 1e-9);

    ASSERT_NEAR(eval.evaluate("neg(-5)").num_val, 5.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("neg(5)").num_val, -5.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("subtract(10, 4)").num_val, 6.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("factorial(5)").num_val, 120.0, 1e-9);
    ASSERT_NEAR(eval.evaluate("reciprocal(4)").num_val, 0.25, 1e-9);

    ASSERT_NEAR(eval.evaluate("round(3.14159, 2)").num_val, 3.14, 1e-9);
    ASSERT_NEAR(eval.evaluate("roundto(3.14159, 2)").num_val, 3.14, 1e-9);
    ASSERT_NEAR(eval.evaluate("round(1234, -2)").num_val, 1200.0, 1e-9);
    }

int main()
    {
    FloatEvaluator rad_eval(AngleMode::Radians);
    FloatEvaluator deg_eval(AngleMode::Degrees);

    test_associativity_and_precedence(rad_eval);
    test_subtraction_vs_multiplication(rad_eval);
    test_implicit_multiplication(rad_eval);
    test_scientific_notation_and_units(rad_eval);
    test_trigonometry_and_angles(rad_eval, deg_eval);
    test_vector_and_scalar_geometry(rad_eval);
    test_modulo_operations(rad_eval);
    test_bitwise_operations(rad_eval);
    test_number_theory(rad_eval);
    test_relations_and_conditionals(rad_eval);
    test_short_circuiting(rad_eval);
    test_arrays_and_indexing(rad_eval);
    test_strings_and_formatting(rad_eval);
    test_math_helpers_and_aliases(rad_eval);

    return g_failed ? 1 : 0;
    }
