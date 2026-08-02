function generate_math_setup(input_file::String, output_file::String)
    open(output_file, "w") do out

        # numbers 0-9 (class 0 = ordinary)
        for c in '0':'9'
            dec = Int(c)
            hex_val = uppercase(lpad(string(dec, base=16), 4, '0'))
            println(out, "\\Umathcode $dec = 0 0 \"$hex_val % $c")
        end
        println(out, "")

        # uppercase A-Z (class 7 = variable)
        offset_A = 0x1D434 - Int('A')
        for c in 'A':'Z'
            dec = Int(c)
            math_hex = uppercase(string(dec + offset_A, base=16))
            println(out, "\\Umathcode $dec = 7 0 \"$math_hex % $c")
        end
        println(out, "")

        # lowercase a-z 
        offset_a = 0x1D44E - Int('a')
        for c in 'a':'z'
            dec = Int(c)
            if c == 'h' #don't forget about the weird unicode hole for h
                println(out, "\\Umathcode $dec = 7 0 \"210E % h (Planck constant exception)")
            else
                math_hex = uppercase(string(dec + offset_a, base=16))
                println(out, "\\Umathcode $dec = 7 0 \"$math_hex % $c")
            end
        end
         
        # maybe someday I'll allow unicode input, in which case...
        # also: non-lunate epsilons, obviously
        greek_lower = [
            ("alpha", 'α', 0x1D6FC), ("beta", 'β', 0x1D6FD), ("gamma", 'γ', 0x1D6FE),
            ("delta", 'δ', 0x1D6FF), ("epsilon", 'ε', 0x1D700), ("zeta", 'ζ', 0x1D701),
            ("eta", 'η', 0x1D702), ("theta", 'θ', 0x1D703), ("iota", 'ι', 0x1D704),
            ("kappa", 'κ', 0x1D705), ("lambda", 'λ', 0x1D706), ("mu", 'μ', 0x1D707),
            ("nu", 'ν', 0x1D708), ("xi", 'ξ', 0x1D709), ("omicron", 'ο', 0x1D70A),
            ("pi", 'π', 0x1D70B), ("rho", 'ρ', 0x1D70C), ("varsigma", 'ς', 0x1D70D),
            ("sigma", 'σ', 0x1D70E), ("tau", 'τ', 0x1D70F), ("upsilon", 'υ', 0x1D710),
            ("phi", 'φ', 0x1D711), ("chi", 'χ', 0x1D712), ("psi", 'ψ', 0x1D713),
            ("omega", 'ω', 0x1D714)
        ]
        # Note the skip at 1D6F3 (which is an alternate Theta symbol)
        greek_upper = [
            ("Alpha", 'Α', 0x1D6E2), ("Beta", 'Β', 0x1D6E3), ("Gamma", 'Γ', 0x1D6E4),
            ("Delta", 'Δ', 0x1D6E5), ("Epsilon", 'Ε', 0x1D6E6), ("Zeta", 'Ζ', 0x1D6E7),
            ("Eta", 'Η', 0x1D6E8), ("Theta", 'Θ', 0x1D6E9), ("Iota", 'Ι', 0x1D6EA),
            ("Kappa", 'Κ', 0x1D6EB), ("Lambda", 'Λ', 0x1D6EC), ("Mu", 'Μ', 0x1D6ED),
            ("Nu", 'Ν', 0x1D6EE), ("Xi", 'Ξ', 0x1D6EF), ("Omicron", 'Ο', 0x1D6F0),
            ("Pi", 'Π', 0x1D6F1), ("Rho", 'Ρ', 0x1D6F2), ("Sigma", 'Σ', 0x1D6F4), 
            ("Tau", 'Τ', 0x1D6F5), ("Upsilon", 'Υ', 0x1D6F6), ("Phi", 'Φ', 0x1D6F7),
            ("Chi", 'Χ', 0x1D6F8), ("Psi", 'Ψ', 0x1D6F9), ("Omega", 'Ω', 0x1D6FA)
        ]

        for (name, char, hex_val) in vcat(greek_lower, greek_upper)
            dec = Int(char)
            hex_str = uppercase(string(hex_val, base=16))
            
            println(out, "\\Umathchardef\\$name = 7 0 \"$hex_str")
        end
        #now, we scrape unicode-math-table.tex

        class_map = Dict(
            "mathord"   => 0,
            "mathalpha" => 7,
            "mathop"    => 1,
            "mathbin"   => 2,
            "mathrel"   => 3,
            "mathopen"  => 4,
            "mathclose" => 5,
            "mathpunct" => 6,
            "mathfence" => 0 
        )

        pattern = r"\\UnicodeMathSymbol\{\"([0-9A-F]+)\}\{\\([a-zA-Z]+)\s*\}\{\\([a-zA-Z]+)\}\{(.*)\}"

        for line in eachline(input_file)
            m = match(pattern, line)
            if m !== nothing
                hex_code, macro_name, math_class, comment = m.captures
                hex_code = uppercase(hex_code)
                comment = strip(comment)
                
                if endswith(comment, "%")
                    comment = strip(comment[1:end-1])
                end

                if math_class == "mathaccent" || math_class == "mathaccentwide"
                    println(out, "\\def\\$macro_name{\\Umathaccent 7 0 \"$hex_code } % $comment")
                elseif math_class == "mathradical"
                    println(out, "\\def\\$macro_name{\\Uradical 0 \"$hex_code } % $comment")
                elseif haskey(class_map, math_class)
                    cls = class_map[math_class]
                    println(out, "\\Umathchardef\\$macro_name = $cls 0 \"$hex_code % $comment")
                else
                    println(out, "% Skipped or unknown class: $line")
                end
            end
        end
        
        println("$(output_file) generated")
    end
end

input_filename = "../tex/unicode-math-table.tex"
output_filename = "math-definitions.tex"

if isfile(input_filename)
    generate_math_setup(input_filename, output_filename)
else
    println("Could not find $input_filename in the current directory.")
end
