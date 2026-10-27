#include "math_alphabets.h"
#include <cassert>

void test_ascii_latin()
    {
    assert(to_base_char('A').codepoint == 'A');
    assert(to_base_char('Z').codepoint == 'Z');
    assert(to_base_char('a').codepoint == 'a');
    assert(to_base_char('z').codepoint == 'z');
    assert(to_base_char('A').is_alphanumeric);
    assert(!to_base_char('A').is_greek);

    assert(apply_math_alphabet('A', MathAlphabet::Default) == 0x1D434); // Mathematical Italic A
    assert(apply_math_alphabet('a', MathAlphabet::Default) == 0x1D44E); // Mathematical Italic a
    assert(apply_math_alphabet('h', MathAlphabet::Default) == 0x210E); // Planck constant h

    assert(apply_math_alphabet('A', MathAlphabet::Upright) == 'A');
    assert(apply_math_alphabet('z', MathAlphabet::Upright) == 'z');

    assert(apply_math_alphabet('A', MathAlphabet::Bold) == 0x1D400);
    assert(apply_math_alphabet('z', MathAlphabet::Bold) == 0x1D433);

    assert(apply_math_alphabet('A', MathAlphabet::BoldItalic) == 0x1D468);
    assert(apply_math_alphabet('z', MathAlphabet::BoldItalic) == 0x1D49B);
    }

void test_bmp_holes()
    {
    assert(apply_math_alphabet('B', MathAlphabet::Script) == 0x212C); // Script B
    assert(apply_math_alphabet('E', MathAlphabet::Script) == 0x2130); // Script E
    assert(apply_math_alphabet('F', MathAlphabet::Script) == 0x2131); // Script F
    assert(apply_math_alphabet('H', MathAlphabet::Script) == 0x210B); // Script H
    assert(apply_math_alphabet('I', MathAlphabet::Script) == 0x2110); // Script I
    assert(apply_math_alphabet('L', MathAlphabet::Script) == 0x2112); // Script L
    assert(apply_math_alphabet('M', MathAlphabet::Script) == 0x2133); // Script M
    assert(apply_math_alphabet('R', MathAlphabet::Script) == 0x211B); // Script R
    assert(apply_math_alphabet('e', MathAlphabet::Script) == 0x212F); // Script e
    assert(apply_math_alphabet('g', MathAlphabet::Script) == 0x210A); // Script g
    assert(apply_math_alphabet('o', MathAlphabet::Script) == 0x2134); // Script o

    assert(apply_math_alphabet('C', MathAlphabet::Fraktur) == 0x212D);
    assert(apply_math_alphabet('H', MathAlphabet::Fraktur) == 0x210C);
    assert(apply_math_alphabet('I', MathAlphabet::Fraktur) == 0x2111);
    assert(apply_math_alphabet('R', MathAlphabet::Fraktur) == 0x211C);
    assert(apply_math_alphabet('Z', MathAlphabet::Fraktur) == 0x2128);

    assert(apply_math_alphabet('C', MathAlphabet::DoubleStruck) == 0x2102);
    assert(apply_math_alphabet('H', MathAlphabet::DoubleStruck) == 0x210D);
    assert(apply_math_alphabet('N', MathAlphabet::DoubleStruck) == 0x2115);
    assert(apply_math_alphabet('P', MathAlphabet::DoubleStruck) == 0x2119);
    assert(apply_math_alphabet('Q', MathAlphabet::DoubleStruck) == 0x211A);
    assert(apply_math_alphabet('R', MathAlphabet::DoubleStruck) == 0x211D);
    assert(apply_math_alphabet('Z', MathAlphabet::DoubleStruck) == 0x2124);

    assert(to_base_char(0x210E).codepoint == 'h');
    assert(apply_math_alphabet(0x210E, MathAlphabet::Default) == 0x210E);
    assert(apply_math_alphabet(0x210E, MathAlphabet::Bold) == 0x1D421); // Bold h

    assert(!to_base_char(0x211C).is_alphanumeric); // \Re (Fraktur R)
    assert(apply_math_alphabet(0x211C, MathAlphabet::Default) == 0x211C); // preserved as \Re
    assert(!to_base_char(0x2111).is_alphanumeric); // \Im (Fraktur I)
    assert(apply_math_alphabet(0x2111, MathAlphabet::Default) == 0x2111); // preserved as \Im
    assert(!to_base_char(0x211D).is_alphanumeric); // \mathbb{R}
    assert(apply_math_alphabet(0x211D, MathAlphabet::Default) == 0x211D);
    }

void test_idempotency_and_plane1_input()
    {
    uint32_t italic_x = 0x1D465;
    assert(to_base_char(italic_x).codepoint == 'x');

    uint32_t bold_x = apply_math_alphabet(italic_x, MathAlphabet::Bold);
    assert(bold_x == 0x1D431); // Bold x

    uint32_t bb_x = apply_math_alphabet(bold_x, MathAlphabet::DoubleStruck);
    assert(bb_x == 0x1D569); // Double-struck x

    assert(apply_math_alphabet(bold_x, MathAlphabet::Bold) == bold_x);
    }

void test_digits()
    {
    assert(to_base_char('0').codepoint == '0');
    assert(to_base_char('9').codepoint == '9');

    assert(apply_math_alphabet('0', MathAlphabet::Default) == '0');
    assert(apply_math_alphabet('5', MathAlphabet::Default) == '5');
    assert(apply_math_alphabet('5', MathAlphabet::Italic) == '5');

    assert(apply_math_alphabet('0', MathAlphabet::Bold) == 0x1D7CE);
    assert(apply_math_alphabet('9', MathAlphabet::Bold) == 0x1D7D7);

    assert(apply_math_alphabet('0', MathAlphabet::DoubleStruck) == 0x1D7D8);
    assert(apply_math_alphabet('9', MathAlphabet::DoubleStruck) == 0x1D7E1);

    assert(to_base_char(0x1D7D3).codepoint == '5'); // Bold 5
    assert(to_base_char(0x1D7DF).codepoint == '7'); // Double-struck 7
    }

void test_greek()
    {
    assert(to_base_char(0x0391).is_greek); // Alpha
    assert(to_base_char(0x03A9).is_greek); // Omega

    assert(to_base_char(0x03B1).is_greek); // alpha
    assert(to_base_char(0x03C9).is_greek); // omega

    assert(apply_math_alphabet(0x0391, MathAlphabet::Default) == 0x0391); // Upright Alpha
    assert(apply_math_alphabet(0x03A9, MathAlphabet::Default) == 0x03A9); // Upright Omega
    assert(apply_math_alphabet(0x03B1, MathAlphabet::Default) == 0x1D6FC); // Italic alpha: 0x1D6E2 + 26 = 0x1D6FC

    assert(apply_math_alphabet(0x0391, MathAlphabet::Bold) == 0x1D6A8); // Bold Capital Alpha
    assert(apply_math_alphabet(0x03B1, MathAlphabet::Bold) == 0x1D6C2); // Bold Small Alpha

    assert(to_base_char(0x1D6A8).codepoint == 0x0391);
    assert(to_base_char(0x1D6C2).codepoint == 0x03B1);
    assert(to_base_char(0x1D6FC).codepoint == 0x03B1); // Italic alpha back to base alpha

    assert(apply_math_alphabet(0x2202, MathAlphabet::Default) == 0x2202); // Upright \partial
    assert(apply_math_alphabet(0x2207, MathAlphabet::Default) == 0x2207); // Upright \nabla
    assert(apply_math_alphabet(0x2202, MathAlphabet::Bold) == 0x1D6DB); // Bold \partial
    assert(apply_math_alphabet(0x2202, MathAlphabet::BoldItalic) == 0x1D74F); // Bold Italic \partial
    assert(apply_math_alphabet(0x2207, MathAlphabet::Bold) == 0x1D6C1); // Bold \nabla
    assert(apply_math_alphabet(0x2207, MathAlphabet::BoldItalic) == 0x1D735); // Bold Italic \nabla

    assert(apply_math_alphabet(0x1D6E4, MathAlphabet::Default) == 0x1D6E4); // Plane 1 Italic Gamma preserved
    assert(apply_math_alphabet(0x1D6FC, MathAlphabet::Default) == 0x1D6FC); // Plane 1 Italic alpha preserved
    assert(apply_math_alphabet(0x1D458, MathAlphabet::Default) == 0x1D458); // Plane 1 Italic k preserved
    }

int main()
    {
    test_ascii_latin();
    test_bmp_holes();
    test_idempotency_and_plane1_input();
    test_digits();
    test_greek();

    return 0;
    }
