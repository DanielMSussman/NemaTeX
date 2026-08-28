# NemaTeX

TeX82 is a remarkable piece of software. As a hobby project, I thought it would be fun to imagine something like "TeX28". That is: what if wanted to design the engine knowing how different document generation is now compared to then. We would probably want to be able to target a variety of output formats (DVI, perhaps, but also PDF and HTML); we would certainly want to be able to directly work with both legacy *and* modern fonts for both text and math; we would want built-in capacities for generating accessible PDFs. We also would want compilation to be fast, and today that means we should be able to actively exploit the multi-threaded architecture of modern chips. But what if, for all of those desires,  we also wanted the engine to still *be* TeX deep down (passing the "trip" test, compiling modern LaTeX documents, etc.)?

This repo is my attempt to explore those questions. If you're interested, I'm also occasionally posting short videos about this project... here's a link to the [youtube playlist](https://www.youtube.com/playlist?list=PLNe1VqvFUSSI)!

## What's up with the name?

I've always thought of this project as just "cpptex", but that name [was taken](https://github.com/syntheticpp/cpptex). I eventually landed on "NemaTeX." 

Keeping a Greek prefix felt in keeping with the etymology of TeX. "Nema" means "thread", and (a) we all love our Knuthian weaving metaphors, (b) one goal of this project was to update the architecture to exploit parallel CPU threads, and (c) well... I've published very tangentially on nematic liquid crystals in my research career.

Finally, in a happy linguistic accident, "nema" can be translated to "there is no" in several Slavic languages. A name for a TeX engine that suggests "there is no TeX" made me chuckle.

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

You can read about the project's history (hope you enjoy!) in [Changelog.md](Changelog.md). My rough plans for future development (and past milestones already finished) can be found in the `notes/` directory.

## Ramble

It's odd to say, but LaTeX is one of those things that makes my life better. I don't have the most sophisticated taste, but when a colleague hands me notes that not only contain beautiful ideas, but are also beautifully typeset... fantastic.

And then I think about TeX itself. There's something humbling about knowing that one of your daily tools predates so much of the rest of your toolbox. Also humbling is how much it taught me about software engineering. For many people, the idea of data-driven design might have clicked when (e.g.) watching [Mike Acton's talk](https://www.youtube.com/watch?v=rX0ItVEVjHc). For me it was when I thought not only about TeX's famous memory word layout, but how the whole system feels like it is fundamentally about how the data *wants* to flow through a typesetting engine. It's a testament that the kinds of optimizations designed for a very different hardware environment -- terribly scarce memory, and with the relative time cost of compute operation and memory look-ups very different from today -- anticipated what is now the cutting edge of data-driven optimization.

Of course... it's not all peaches and cream. I am, frankly, not smart enough to reason about how parts of the TeX code -- in Pascal or the macro-laden cweb translation -- actually work together. I find it too much to hold in my head at once. Certainly I would enjoy it if the code of TeX was written in a way more familiar to how I learned to write C++ -- not so much in the sense of object orientation, but in the sense of interfaces, abstractions, minimal global state, and without a spaghetti of macros interconnecting everything.

There's a rough planning document in the `notes/` directory, but even a cursory inspection of the code itself will tell you that I'm kind of going through and updating the code in waves. Some functions will look very much like a direct translation of the original pascal code, and some will look like modern(ish) C++. I also wanted to advertise other people's work in the community. Of course engines like pdftex, xetex, and luatex make modern LaTeX possible, but many others have played around with the idea of writing TeX in a modern language, too. I'd like to particularly highlight projects like arusson's [tex-c](https://github.com/arusson/tex-c), Richard Sandberg's [rsTeX](https://github.com/nadder/rstex), and Tyge Tiessen's [rtex](https://github.com/tyti/rtex)). I learned a lot by looking at those codebases.

## Thanks?

If you find this project interesting and would like to offer support: [Buy Me a Coffee!](https://www.buymeacoffee.com/danielmsussman).
