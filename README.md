# NemaTeX

TeX82 is a remarkable piece of software. As a hobby project, I thought it would be fun to imagine something like "TeX28".

What if we designed a modern engine knowing our current targets? We would probably want an engine that abstracts over different font types, includes built-in primitives for generating accessible (tagged) PDFs, targets a variety of formats (DVI, PDF, HTML), and exploits modern hardware through concurrent calculations. But what if, for all of those desires,  we also wanted the engine to still *be* TeX: passing the trip test, compiling modern LaTeX documents, and remaining true to its roots.

In addition to documents here in the repo, I'm occasionally posting short videos about this engine. You can check out the [youtube playlist](https://www.youtube.com/playlist?list=PLNe1VqvFUSSI) if you're interested!

## What's up with the name?

I've always thought of this project as just "cpptex", but that name [was taken](https://github.com/syntheticpp/cpptex). I eventually landed on "NemaTeX." 

Keeping a Greek prefix felt in keeping with the etymology of TeX. "Nema" means "thread", and (a) we all love our Knuthian weaving metaphors, (b) a primary goal of this project was to update the architecture to exploit parallel CPU threads, and (c) well... I've published very tangentially on nematic liquid crystals in my research career.

Finally, in a happy linguistic accident, "nema" can be translated to "there is no" in several Slavic languages. A name that suggests "there is no TeX" made me chuckle too much to pick anything else.

## Building the project

We're using CMake for a standard out-of-source build. To get started:

```bash
mkdir build
cd build
cmake ..
cmake --build . -j
ctest
```

## Changelog and rough planning

You can read about the project's history (hope you enjoy!) in [ChangeLog.md](ChangeLog.md). My rough plans for future development (and past milestones already finished) can be found in the `notes/` directory.

## Third party components

This contains components from other open-source projects. Overall information, including where to find the relevant license files, can be found in the `licenses/` directory. The `extern/` directory additionally includes license information for [miniz](https://github.com/richgel999/miniz)  (MIT license) for zlib deflation, [argh](https://github.com/adishavit/argh) (BSD-3) for command-line parsing, [stb_image](https://github.com/nothings/stb) (MIT or Unlicense) for asset decoding, and [woff2](https://github.com/google/woff2) (MIT) for font compression.


## Ramble

It's odd to say, but LaTeX is one of those things that makes my life better. I don't have the most sophisticated taste, but when a colleague hands me notes that not only contain beautiful ideas, but are also beautifully typeset... fantastic.

And then I think about TeX itself. There's something humbling about knowing that one of your daily tools predates so much of the rest of your toolbox. Also humbling is how much it taught me about software engineering. For many people, the idea of data-driven design might have clicked when (e.g.) watching [Mike Acton's talk](https://www.youtube.com/watch?v=rX0ItVEVjHc). For me it was when I thought not only about TeX's famous memory word layout, but how the whole system feels like it is fundamentally about how the data *wants* to flow through a typesetting engine. It's a testament that the kinds of optimizations designed for a very different hardware environment -- terribly scarce memory, and with the relative time cost of compute operation and memory look-ups very different from today -- anticipated what is now the cutting edge of data-driven optimization.

Of course... it's not all peaches and cream. I am, frankly, not smart enough to reason about how parts of the TeX code -- in Pascal or the macro-laden cweb translation -- actually work together. I find it too much to hold in my head at once. Certainly I would enjoy it if the code of TeX was written in a way more familiar to how I learned to write C++ -- not so much in the sense of object orientation, but in the sense of interfaces, abstractions, minimal global state, and without a spaghetti of macros interconnecting everything.

I'm hardly the first to play around with writing TeX in a modern language outside of the context of pdftex/xetex/luatex (and I'd like to particularly highlight projects like arusson's [tex-c](https://github.com/arusson/tex-c), Richard Sandberg's [rsTeX](https://github.com/nadder/rstex), and Tyge Tiessen's [rtex](https://github.com/tyti/rtex)).


## Thanks?

If you find this project interesting and would like to offer support: [Buy Me a Coffee!](https://www.buymeacoffee.com/danielmsussman)
