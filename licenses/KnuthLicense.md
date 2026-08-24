# tex

The original `tex.web` source code was distributed under the following terms:

    % This program is copyright (C) 1982 by D. E. Knuth; all rights are reserved.
    % Unlimited copying and redistribution of this file are permitted as long
    % as this file is not modified. Modifications are permitted, but only if
    % the resulting file is not named tex.web. (The WEB system provides
    % for alterations via an auxiliary file; the master file should stay intact.)

Modifications have been made to the source in this repository, and per the license requirements, no file in this repository is named `tex.web`. The resulting executable is also not called `tex`.

## Trip test compliance

Knuth requested a specific criteria for implementations of TeX:

>If somebody claims to have a correct implementation of TeX, I will not believe it until I see that TRIP.TEX is translated properly. I propose, in fact, that a program must meet two criteria before it can justifiably be called TeX: (1) The person who wrote it must be happy with the way it works at his or her installation; and (2) the program must produce the correct results from TRIP.TEX.
>
>TeX is in the public domain, and its algorithms are published; I've done this since I do not want to discourage its use by placing proprietary restrictions on the software. However, I don't want faulty imitations to masquerade as TeX processors, since users want TeX to produce identical results on different machines. Hence I am planning to do whatever I can to suppress any systems that call themselves TeX without meeting conditions (1) and (2). I have copyrighted the programs so that I have some chance to forbid unauthorized copies; I explicitly authorize copying of correct TeX implementations, and not of incorrect ones!

I am, indeed, happy with the way my program works at my installation. Furthermore, this repo includes running the TRIP test as part of its automated test suite (see the `CMakeLists.txt` files and `test/triptest/` for more details). This ensures the core engine logic remains faithful to the original specifications, even as I change the internal architecture and add functionality.

# other files

The `assets/formats/` dir contains the files `plain.tex` and `hyphen.tex`, copied unmodified from [CTAN](https://ctan.org/pkg/plain?lang=en) and distributed under the Knuth License:

    % The Plain TeX hyphenation tables [NOT TO BE CHANGED IN ANY WAY!]
    % Unlimited copying and redistribution of this file are permitted as long
    % as this file is not modified. Modifications are permitted, but only if
    % the resulting file is not named hyphen.tex.

and

    % Unlimited copying and redistribution of this file are permitted as long
    % as this file is not modified. Modifications are permitted, but only if
    % the resulting file is not named plain.tex.

There *is* a modified version of plain.tex, called `ua2plain.tex`. It copies and modifies plain.tex, and thus has a different name.

In order to work with `plain.tex`, the `assets/tex/fonts` directory contains the [computer modern](https://ctan.org/tex-archive/fonts/cm/tfm?lang=en) `.tfm` font files. It also contains [font info for the manual](https://ctan.org/tex-archive/fonts/manual/tfm) (the `manfnt.tfm` file). All of these are under the Knuth License:

    This software is copyrighted. Unlimited copying and redistribution of this package
    and/or its individual files are permitted as long as there are no modifications.
    Modifications, and redistribution of modifications, are also permitted, but only
    if the resulting package and/or files are renamed. 

