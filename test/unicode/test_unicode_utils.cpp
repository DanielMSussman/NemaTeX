#include "common/enums.h"
#include "utility/codepoint_utils.h"
#include "utility/unicode_utils.h"

#include <cassert>
#include <iostream>
#include <string>
#include <vector>

/*
On the one hand, the unicode library we're using has a much better test suite (obviously)...
on the other hand, it's good to check that we've wired our interface to that library without
making trivial mistakes.
*/
static bool g_failed = false;

#define ASSERT_TRUE(cond)                                                                                                                  \
    do                                                                                                                                     \
        {                                                                                                                                  \
        if (!(cond))                                                                                                                       \
            {                                                                                                                              \
            std::cerr << "Assertion failed: " #cond << " at " << __FILE__ << ":" << __LINE__ << std::endl;                                 \
            g_failed = true;                                                                                                               \
            }                                                                                                                              \
        } while (0)

#define ASSERT_EQ(a, b)                                                                                                                    \
    do                                                                                                                                     \
        {                                                                                                                                  \
        if ((a) != (b))                                                                                                                    \
            {                                                                                                                              \
            std::cerr << "Assertion failed: (" #a ") == (" #b ") at " << __FILE__ << ":" << __LINE__ << std::endl;                         \
            g_failed = true;                                                                                                               \
            }                                                                                                                              \
        } while (0)

void test_validation_and_length()
    {
    ASSERT_TRUE(UnicodeUtils::is_valid_utf8("Hello World"));
    ASSERT_TRUE(UnicodeUtils::is_valid_utf8("café"));
    ASSERT_TRUE(UnicodeUtils::is_valid_utf8("αβγ"));
    //He tasks me; he heaps me; I see in him outrageous strength, with an inscrutable malice sinewing it
    ASSERT_TRUE(UnicodeUtils::is_valid_utf8("🐳"));
    ASSERT_TRUE(UnicodeUtils::is_valid_utf8(""));

    ASSERT_TRUE(!UnicodeUtils::is_valid_utf8("\x80"));
    ASSERT_TRUE(!UnicodeUtils::is_valid_utf8("\xC3"));
    ASSERT_TRUE(!UnicodeUtils::is_valid_utf8("\xFF"));

    ASSERT_EQ(UnicodeUtils::utf8_length("Hello"), 5);
    ASSERT_EQ(UnicodeUtils::utf8_length("café"), 4);
    ASSERT_EQ(UnicodeUtils::utf8_length("αβγ"), 3);
    ASSERT_EQ(UnicodeUtils::utf8_length("🐳"), 1);
    ASSERT_EQ(UnicodeUtils::utf8_length(""), 0);

    // now some stuff that is harder for me to read:
    //  invalid continuation byte.
    ASSERT_TRUE(!UnicodeUtils::is_valid_utf8("\xC2\x41"));
    // overlong encodings of ASCII characters.
    ASSERT_TRUE(!UnicodeUtils::is_valid_utf8("\xC0\xAF"));
    // utf8 encodings of surrogate code points are invalid.
    ASSERT_TRUE(!UnicodeUtils::is_valid_utf8("\xED\xA0\x80"));
    // code points above U+10FFFF are invalid.
    ASSERT_TRUE(!UnicodeUtils::is_valid_utf8("\xF4\x90\x80\x80"));
    // truncated multi-byte sequences
    ASSERT_TRUE(!UnicodeUtils::is_valid_utf8("\xE2\x82"));
    ASSERT_TRUE(!UnicodeUtils::is_valid_utf8("\xF0\x9F\x90"));
    // valid supplementary-plane character (gclef)
    ASSERT_TRUE(UnicodeUtils::is_valid_utf8("𝄞"));
    ASSERT_EQ(UnicodeUtils::utf8_length("𝄞"), 1);
    }

void test_conversions()
    {
    Utf8Char u_ascii = UnicodeUtils::encode_utf8('A');
    ASSERT_EQ(u_ascii.len, 1);
    ASSERT_EQ(u_ascii.view(), "A");
    ASSERT_EQ(std::string_view(u_ascii), "A");
    ASSERT_EQ(*u_ascii.begin(), 'A');
    ASSERT_EQ(u_ascii.end() - u_ascii.begin(), 1);

    Utf8Char u_2byte = UnicodeUtils::encode_utf8(U'é');
    ASSERT_EQ(u_2byte.len, 2);
    ASSERT_EQ(u_2byte.view(), "é");

    Utf8Char u_3byte = UnicodeUtils::encode_utf8(U'€');
    ASSERT_EQ(u_3byte.len, 3);
    ASSERT_EQ(u_3byte.view(), "€");

    Utf8Char u_4byte = UnicodeUtils::encode_utf8(U'🐳');
    ASSERT_EQ(u_4byte.len, 4);
    ASSERT_EQ(u_4byte.view(), "🐳");

    Utf8Char u_invalid = UnicodeUtils::encode_utf8(-1);
    ASSERT_EQ(u_invalid.len, 3);
    ASSERT_EQ(u_invalid.view(), "\xEF\xBF\xBD");

    Utf8Char u_surrogate = UnicodeUtils::encode_utf8(0xD800);
    ASSERT_EQ(u_surrogate.len, 3);
    ASSERT_EQ(u_surrogate.view(), "\xEF\xBF\xBD");

    std::string appended;
    UnicodeUtils::append_utf8(appended, 'H');
    UnicodeUtils::append_utf8(appended, U'é');
    UnicodeUtils::append_utf8(appended, U'€');
    UnicodeUtils::append_utf8(appended, U'🐳');
    ASSERT_EQ(appended, "Hé€🐳");

    ASSERT_EQ(UnicodeUtils::codepoint_to_utf8('A'), "A");
    ASSERT_EQ(UnicodeUtils::codepoint_to_utf8(U'é'), "é");
    ASSERT_EQ(UnicodeUtils::codepoint_to_utf8(U'α'), "α");
    ASSERT_EQ(UnicodeUtils::codepoint_to_utf8(U'🐳'), "🐳");

    std::vector<Codepoint> cps = {U'Н', U'е', U'м', U'а', ' ', 'T', 'e', 'X'};
    ASSERT_EQ(UnicodeUtils::codepoints_to_utf8(cps), "Нема TeX");

    std::string scratch;
    std::string_view sv = UnicodeUtils::codepoints_to_utf8(cps, scratch);
    ASSERT_EQ(sv, "Нема TeX");
    ASSERT_EQ(sv.data(), scratch.data());

    std::vector<halfword> toks = {TokenUtils::pack(letter, 'r'), TokenUtils::pack(letter, U'é'), TokenUtils::pack(letter, 's'),
                                  TokenUtils::pack(letter, 'u'), TokenUtils::pack(letter, 'm'),  TokenUtils::pack(letter, U'é')};
    ASSERT_EQ(UnicodeUtils::tokens_to_utf8(toks), "résumé");

    std::string tok_scratch;
    std::string_view tok_sv = UnicodeUtils::tokens_to_utf8(toks, tok_scratch);
    ASSERT_EQ(tok_sv, "résumé");
    ASSERT_EQ(tok_sv.data(), tok_scratch.data());

    std::vector<halfword> other_toks;
    UnicodeUtils::append_utf8_as_other_tokens("a é 1", other_toks);
    ASSERT_EQ(other_toks.size(), 5);
    ASSERT_EQ(other_toks[0], TokenUtils::pack(other_char, 'a'));
    ASSERT_EQ(other_toks[1], space_token);
    ASSERT_EQ(other_toks[2], TokenUtils::pack(other_char, U'é'));
    ASSERT_EQ(other_toks[3], space_token);
    ASSERT_EQ(other_toks[4], TokenUtils::pack(other_char, '1'));

    auto decoded_cps = UnicodeUtils::utf8_to_codepoints("Нема TeX");
    ASSERT_EQ(decoded_cps.size(), 8);
    ASSERT_EQ(decoded_cps[0], U'Н');
    ASSERT_EQ(decoded_cps[1], U'е');
    ASSERT_EQ(decoded_cps[2], U'м');
    ASSERT_EQ(decoded_cps[3], U'а');
    ASSERT_EQ(decoded_cps[4], ' ');
    ASSERT_EQ(decoded_cps[5], 'T');
    ASSERT_EQ(decoded_cps[6], 'e');
    ASSERT_EQ(decoded_cps[7], 'X');

    std::vector<Codepoint> decoded_vec;
    UnicodeUtils::utf8_to_codepoints("Нема TeX", decoded_vec);
    ASSERT_EQ(decoded_vec.size(), 8);
    for (size_t i = 0; i < 8; ++i)
        ASSERT_EQ(decoded_vec[i], decoded_cps[i]);
    }

void test_line_decoding()
    {
    std::vector<Codepoint> buffer(32, 0);

    size_t count = UnicodeUtils::decode_utf8_nfc_line("Hello TeX", buffer, 5);
    ASSERT_EQ(count, 9);
    ASSERT_EQ(buffer[5], 'H');
    ASSERT_EQ(buffer[13], 'X');

    std::string line_with_null = "a";
    line_with_null += '\0';
    line_with_null += 'b';
    count = UnicodeUtils::decode_utf8_nfc_line(line_with_null, buffer, 0);
    ASSERT_EQ(count, 2);
    ASSERT_EQ(buffer[0], 'a');
    ASSERT_EQ(buffer[1], 'b');

    std::string decomposed = "e\xCC\x81"; // U+0065 + U+0301
    count = UnicodeUtils::decode_utf8_nfc_line(decomposed, buffer, 0);
    ASSERT_EQ(count, 1);
    ASSERT_EQ(buffer[0], U'é');

    std::vector<Codepoint> small_buffer(4, 0);
    count = UnicodeUtils::decode_utf8_nfc_line("A very long line that exceeds small buffer capacity", small_buffer, 2);
    ASSERT_EQ(count, 51);
    ASSERT_TRUE(small_buffer.size() >= 53);
    ASSERT_EQ(small_buffer[2], 'A');
    }

void test_case_mapping()
    {
    ASSERT_EQ(UnicodeUtils::to_lowercase('A'), 'a');
    ASSERT_EQ(UnicodeUtils::to_lowercase('a'), 'a');
    ASSERT_EQ(UnicodeUtils::to_lowercase(U'Ω'), U'ω');
    ASSERT_EQ(UnicodeUtils::to_lowercase(U'ß'), U'ß'); // we're doing simple, 1cp case mapping

    ASSERT_EQ(UnicodeUtils::to_uppercase('a'), 'A');
    ASSERT_EQ(UnicodeUtils::to_uppercase('A'), 'A');
    ASSERT_EQ(UnicodeUtils::to_uppercase(U'ω'), U'Ω');
    ASSERT_EQ(UnicodeUtils::to_uppercase(U'ß'), U'ß');

    ASSERT_TRUE(UnicodeUtils::is_lowercase('a'));
    ASSERT_TRUE(!UnicodeUtils::is_lowercase('A'));
    ASSERT_TRUE(UnicodeUtils::is_lowercase(U'ω'));
    ASSERT_TRUE(!UnicodeUtils::is_lowercase(U'Ω'));

    ASSERT_TRUE(UnicodeUtils::is_uppercase('A'));
    ASSERT_TRUE(!UnicodeUtils::is_uppercase('a'));
    ASSERT_TRUE(UnicodeUtils::is_uppercase(U'Ω'));
    ASSERT_TRUE(!UnicodeUtils::is_uppercase(U'ω'));
    }

void test_general_category()
    {
    ASSERT_TRUE(UnicodeUtils::is_letter_or_mark('a'));
    ASSERT_TRUE(UnicodeUtils::is_letter_or_mark('Z'));
    ASSERT_TRUE(UnicodeUtils::is_letter_or_mark(U'α'));
    ASSERT_TRUE(!UnicodeUtils::is_letter_or_mark('0'));
    ASSERT_TRUE(!UnicodeUtils::is_letter_or_mark('+'));

    ASSERT_TRUE(UnicodeUtils::is_math_symbol_or_currency('+'));
    ASSERT_TRUE(UnicodeUtils::is_math_symbol_or_currency('='));
    ASSERT_TRUE(UnicodeUtils::is_math_symbol_or_currency('<'));
    ASSERT_TRUE(UnicodeUtils::is_math_symbol_or_currency('$'));
    ASSERT_TRUE(UnicodeUtils::is_math_symbol_or_currency(U'€'));
    ASSERT_TRUE(!UnicodeUtils::is_math_symbol_or_currency('a'));

    ASSERT_TRUE(UnicodeUtils::is_open_punctuation('('));
    ASSERT_TRUE(UnicodeUtils::is_open_punctuation('['));
    ASSERT_TRUE(!UnicodeUtils::is_open_punctuation(')'));
    ASSERT_TRUE(!UnicodeUtils::is_open_punctuation(']'));

    ASSERT_TRUE(UnicodeUtils::is_close_punctuation(')'));
    ASSERT_TRUE(UnicodeUtils::is_close_punctuation(']'));
    ASSERT_TRUE(!UnicodeUtils::is_close_punctuation('('));

    ASSERT_TRUE(UnicodeUtils::is_final_punctuation(U'»'));
    ASSERT_TRUE(!UnicodeUtils::is_final_punctuation('a'));

    ASSERT_EQ(UnicodeUtils::general_category('A'), UnicodeGeneralCategory::UppercaseLetter);
    ASSERT_EQ(UnicodeUtils::general_category('a'), UnicodeGeneralCategory::LowercaseLetter);
    ASSERT_EQ(UnicodeUtils::general_category(U'α'), UnicodeGeneralCategory::LowercaseLetter);
    ASSERT_EQ(UnicodeUtils::general_category('+'), UnicodeGeneralCategory::MathSymbol);
    ASSERT_EQ(UnicodeUtils::general_category('$'), UnicodeGeneralCategory::CurrencySymbol);
    ASSERT_EQ(UnicodeUtils::general_category(U'€'), UnicodeGeneralCategory::CurrencySymbol);
    ASSERT_EQ(UnicodeUtils::general_category('('), UnicodeGeneralCategory::OpenPunctuation);
    ASSERT_EQ(UnicodeUtils::general_category(')'), UnicodeGeneralCategory::ClosePunctuation);
    ASSERT_EQ(UnicodeUtils::general_category(U'»'), UnicodeGeneralCategory::FinalPunctuation);
    }

void test_utf8_round_trips()
    {
    const std::vector<Codepoint> input = {U'A', U'é', U'α', U'Н', U'🐳', U'\u0301'};

    const std::string utf8 = UnicodeUtils::codepoints_to_utf8(input);
    const auto decoded = UnicodeUtils::utf8_to_codepoints(utf8);

    ASSERT_EQ(decoded.size(), input.size());

    for (size_t i = 0; i < input.size(); ++i)
        ASSERT_EQ(decoded[i], input[i]);
    }

void test_streaming_and_iteration()
    {
    std::string text = "Нема TeX 🐳";
    std::vector<Codepoint> streamed_cps;
    UnicodeUtils::for_each_utf8_codepoint(text, [&](Codepoint cp) {
        streamed_cps.push_back(cp);
    });
    auto direct_cps = UnicodeUtils::utf8_to_codepoints(text);
    ASSERT_EQ(streamed_cps.size(), direct_cps.size());
    for (size_t i = 0; i < streamed_cps.size(); ++i)
        ASSERT_EQ(streamed_cps[i], direct_cps[i]);

    std::string emitted_bytes;
    UnicodeUtils::for_each_utf8_byte(U'🐳', [&](uint8_t b) {
        emitted_bytes.push_back(static_cast<char>(b));
    });
    ASSERT_EQ(emitted_bytes, "🐳");
    }

int main()
    {
    test_validation_and_length();
    test_conversions();
    test_line_decoding();
    test_case_mapping();
    test_general_category();
    test_utf8_round_trips();
    test_streaming_and_iteration();

    if (g_failed)
        return 1;

    return 0;
    }
