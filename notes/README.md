*But, Mousie, thou art no thy lane,* and all that, except these aren't even best-laid.

# Refactoring roadmap 

The first few milestones are all about incremental refactoring; the guiding principle is that we will start with a working tex82 implementation in c (web2c source?), and incrementally refactor it (as opposed to starting from the TeXBook and a blank slate). At all times we will try to keep the trip test passing, while trying to make the code more modular, more declarative, easier to reason about, etc.

A rough roadmap is planned out below; adjustments will be made as we go, and the milestones will not be done strictly in order.


## Milestone 0: Foundations and build automation (tedious / trivial / done. Forgot to track time. Lets say 8 hours to get the build and first trip integration right)

Goal: set up basic infrastructure to make development and testing more convenient.

- [x] Use CMake: We have an out-of-source build process that is easy / standard.

- [x] Integrate Trip Test via CTest: Implemented an automated test that compiles the code, runs it on `trip.tex` twice, and verifies the output against the canonical `trip.log`.
    - [x] Each of the two runs uses the tripman.tex's specified sequence of keypresses (as encoded, e.g., in the `triptest/first_trip_input.txt` file), and compares the outputs to the canonical ones. The `triptest/CompareLogs.cmake` script does some simple regex stuff so that some parts of the trip.log file that are *allowed* to be different (dates, string numbers... see CompareX.cmake for details) still pass the test.
    - [x] (From milestone 2 work): the DVI comparison part of the trip test is now also implemented.

## Milestone 1: Basic decomposition and mechanical cleanup (easy. 15-ish hours, but some of that blended together with milestone 0)

Goal: Make a bunch of elementary (mostly mechanical) changes to the c source, without altering actual algorithms or data structures. These changes should help prepare for encapsulation in the next Milestone.

- [x] Convert Preprocessor Macros to Inline Functions: Systematically replace most function-like macros (`#define`) with `inline` C++ functions.

- [x] Decompose Monolithic File: 20k lines of code is too many all at once. Start by breaking down the monolithic file into a collection of headers to begin clarifying dependencies.
    - [x] Collect global variables: All global variables get put in a single file.

- [x] Create separate compilation units: We're not actually untangling anything yet, but we're setting up cmake so that a few "libraries" get compiled and linked together (broad strokes: IO, mathlists, scanning, linebreaking, etc).
    - [x] extern shenanigans on the global variables so that separate compilation will still work with everything accessing everything.


## Milestone 2: Encapsulation of global state and removal of gotos (plenty of work, but straightforward. 33-ish hours)

Goal: global state is encapsulated (and perhaps starts to be spread among natural units). Also, get rid of goto statements and replace them with state machines, functions, and loops

- [x] Consolidate Global State: Create a single "god `TeXEngineState` struct" that contains every global variable from the program. Functions modified to access state through a single global instance of this struct (e.g., `state->selector` instead of `selector`).

- [x] Pass `TeXEngineState` Explicitly to Functions: Modify every function to accept a reference to the `TeXEngineState` struct. Success means no longer having a `cpptex_globals.h` file.

- [x] Reduction of goto statements: replace complex goto logic in core functions (like `main_control`) with more readable/understandable (?) enum-based state machines. Should help make the code more testable, and help enable further modularization in the next milestone.

- [x] Decompose `TeXEngine` Break down the monolithic `TeXEngine` class into smaller, collaborating classes with single responsibilities (e.g., `Scanner`, `Parser`, `MemoryManager`, `PageBuilder`), to the extent possible.

- [x] Identification of "leaf" components: Even at this stage, it is clear that some components can be split off from the TeXEngineState struct: the memory array, the logger, etc.
    * At this stage, we still allow entangled behavior even for a "leaf" node. For instance, the TeXMemory needs to `succumb()`, or the logger needs to access `new_line_char()` from the eqtb. This will be done with member reference variables and callback functions for now. The TeXEngineState constructor will be responsible for setting these interdependencies.

- [x] Pass `TeXEngineState` everywhere: Modify every function to accept a reference to the `TeXEngineState` struct. Success means there is no longer a global state, and only `int main()` creates an engine state.

## Milestone 3: Actual Refactoring (120 hours-ish)

With the state encapsulated, this milestone tackles the internal logic and structure of the engine itself.

- [x] eliminate goto statements

- [x] refactored fontmanager to route calls through FontInterfaces, and replaced the old tfm functions with a LegacyFont class.

- [x] pageIR 

- [x] Lots of internal rearrangement

## Milestone 4: pdf output and otf fonts (60-ish? I've stopped keeping careful track)

- [x] harfbuzz for opentype fonts

- [x] basic unicode math 

- [x] basic pdf output

- [x] partial reorganization of texenginestate
    - [x] Reporter facade for logger / interaction manager / error handler
    - [x] ListBuilder class that owns par / align / box / math by composition (produce lists from tokens)

## Milestone 5: Tagging and architecture 

- [x] better unicode math

- [x] more complete otf integration with harfbuzz. Generalize things like `get_ligature_interaction` to `shape_run`. Give OTF fonts access to traditional tex ligatures.

- [x] basic pdf and mathml tagging

## Milestone 6: Architecture, cleaning, improvements, part 1

...Many of the above implementations are the basic version. There's lots of cleaning, refactoring, and improvement to work on. The goal is to carve nature at the joints; for now we've hacked at it with a spoon.

- [x] Null output driver 

- [x] "File registry" for more cohesive handling of file paths / names / extensions across engine and reporters

- [x] Cmake subsystem organiziation, and corresponding class / function organiztion
    - [x] Press
    - [x] Utils
    - [x] Diagnostics
    - [x] Assets
    - [x] Tagging
    - [x] Fonts
    - [x] State
    - [x] Hyphenation

## Milestone 7: Architecture, cleaning, improvements, part 2

...Many of the above implementations are the basic version. There's lots of cleaning, refactoring, and improvement to work on. The goal is to carve nature at the joints; for now we've hacked at it with a spoon.


- [x] Various primitives, etc
    - [x] tex engine version / existence
    - [x] update timer to align with pdftex (for l3kernel)

- [ ] continued state decoupling and class organization.
    - [ ] compositor/typesetter/scanner/engine entanglements... pretty fundamental, but think about it 
    - [x] LineBreaker -- finish extracting a KnuthPlass core that is independent of the engine state
    - [ ] math list -- extract out the math AST noads from the main Memory
        - [ ] math AST: small variant with side tables a la the pageIR
            - [ ] freeing and error recovery -- walk once to tell the memory to clean nodes up if needed, then `.clear()`
        - [ ] remove noads from the node organization and the texmemory class altogether
    - [ ] font manager and font interface need to be refactored. Font stores, TeX-related font interfaces, and then a simpler manager. The kind of thing we can pass around with no reference to the engine (i.e., what the output routines want to have)
    - [ ] fold away / reorganize interaction manager and display printers

- [x]  make an iterator for the texMemory, replacing a lot of the `while (p!=nullword)` stuff
    - [x] use throughout where appropriate
    
## Milestone 8: Architecture, cleaning, improvements, part 3 (deeper font stuff, etc)

- [ ] primitives for selecting otf font features (or disabling tex ligatures)

- [ ] OTF Math -- check the many lingering issues (`ua2gentle` math chapter shows a few inconsistencies. Surds.)

- [ ] comment in OTF reconstituter header. 
    - [ ] OTF reconstituter improvements
    - [ ] carefully work through assumptions in the linebreaker (char nodes vs glyph nodes, etc) 

- [ ] font selection scheme for text and math. See `notes/fonts.md` (and related to the above)

- [ ] `src/common` sudirectory. Are we happy with the things that are in this space?
    - [ ] constant
    - [ ] enums
    - [ ] helpers
    - [ ] structs
    - [ ] types

## Milestone 9: macro storage and dynamic memory

- [ ] macros / immutable token sequences separate memory arrays / vectors? (`notes/tokenStore.md`)


## Milestone 10: e-TeX and LaTeX

- [ ] e-tex extensions (`notes/etex.md`)
- [ ] things required for the l3 kernel (`notes/l3kernel.md`)
    - [ ] think more about expl3
- [ ] audit engine constants
    - [ ] reimplement hash table (current fingerprinting limits cs capacity to 16387)
    - [x] Put the string pool on the heap as a vector
    - [ ] fix the limited `max_halfword` kludge

## Milestone 11: error messages

- [x] allow swapping the tex error reporter with a different one (`notes/errors.md`)
    - [x] proof of principle implementation with clang-inspired diagnostics for 3-4 types of errors
- [ ] expressive errors for all messages (?)
    - [ ] decision: do we actually want to introduce token provenance? If so, how?

## Milestone 12: Basic HTML generation

Frustrated with trying to get videos in pfds to work, it's time to implement a fixed-layout html generator. Should be visually the same as pdf output

- [x] base class to handle common boilerplate and fonts

- [x] fixed-layout HTML

- [x] cleaning
    - [x] separate out harfbuzz subsetting to be used by both html and pdf
    - [x] implement a system of compression for html, with brotli only at level 9

- [x] primitive merging: things like `\pdfpageheight` should just be an alias for a more general pageheight macro, etc.

## Milestone 13: Semantic HTML generation

In addition to fixed-layout, we should have semantic html (reflowable text, mathML instead of drawing glyphs, blah blah)

- [ ] semantic HTML output

- [ ] cleaning
    - [ ] refactor possibly duplicative state-tracking in html and pdf generators
    - [ ] parallelize html generation

- [ ] this would be an excellent time to actually set up our tagging tests both for html and pdf. A few sample files are in the `test/tagging` directory to think about.

## Milestone 14: Parallel execution macros

Goal: introduce engine-level primitives to allow safe, concurrent macro expansion and layout without corrupting TeX's heavily mutated global state. Don't worry: I appreciate that this is ridiculous.

- [ ] Implement Copy-On-Write (COW) `eqtb`?: One possible idea is to think about the paged array structure of the eqtb, but as shared pointers? This would give read-only snapshots for background threads, while the main thread only has to copy pages it mutates.
- [ ] thread-local memory arenas: Needs something for the background threads so they can run `get_node`/`free_node` without locking the global `mem` array. Bump allocators?
- [ ] Isolate string pools and scanners: Ensure background threads have independent input contexts so they don't advance the main file pointer, and string buffers that only merge to the global pool upon completion.
- [ ] primary primitives
    - [ ] `\parallelmeasure`: A "pure oracle" primitive for side-effect-free measurement (e.g., table cells). Evaluates tokens in the background, returns physical dimensions to the main thread, and instantly discards its local node tree.
    - [ ] `\asyncbox`: A promise-based primitive (e.g., `\setbox0=\asyncbox{...}`). Dispatches layout work to a background thread and merges its node arena into the global pool on completion (?). The main thread only blocks if it attempts to access the box before the promise resolves.
    - [ ] `\spawnengine`: A clean, completely isolated sub-engine primitive to natively parallelize heavy standalone tasks (like `TikZ` graphics or independent chapters) without the overhead of OS-level process spawning. Have to think hard and refine what exactly the output of an "engine" is... what IR, what internal state should be transmitted, what final output, etc.

# Milestone 15: Smoother self-cycling

- [ ] engine self-signalling: to help with multipass compilation, give the engine a way to detect that it needs to run again, and optionally let this signal restart an outer loop from the main exexcutable.

# Milestone 16: unicode input

Currently, the `input_character_map` just enforces 7 (7!)-bit input (but our nodes are arranged to have room for 21 bits). We should build out an actual unicode scanner that can hand the engine codepoints, and then start confronting all of the times that the number `256` is used in the codebase


# Milestone X:  unsorted ideas (i.e., the staging ground for future milestones)

- [ ] Revisit pageIR. 
    - [ ] Drawing operations?
    - [ ] proliferation of special, beginspecial, endspecial, the structure open/close things... can/should these be pared down? Is the full state machine for the begin/end specials implemented, or is it only used in html, etc?
        - [ ] sub-aim: audit all new primitives, etc, both in their function and their organization
        - [ ] specials: probably restrict to special and scopedspecial

- [ ] IR of enough state and memory before linebreaking?

- [ ] Dynamic / resizing memory vector

- [ ] citations (eplain? something else?)

- [ ] more pdf flexibility (`notes/pdf.md`)

- [ ] anything still in the notes directory

# Milestone Y: Strict mode

Perhaps the parallel primitives could then be used to re-imagine how TeX works for "standard" documents. I'm imagining two primary components that would substantially help, while still maintaining the full ability of TeX to work.

### Transparent keywords

The first is a dynamically configurable set of keywords that you promise are transparent in the main body of the document, where by "transparent" I mean "trivially scannable by a preprocessor rather than the full tex engine". For instance,  `\input`, `\include`, `\chapter`, `\section`, `\begin{x}...\end{x}` (for a subset of `x`) are transparent, a preprocessor could very quickly build a DOM that could then be accessed by the TeX engine's actual run to have already resolved label references and citations. Page references would still require multiple compilation (of at least some parts of a document), but this would allow single-pass compilation rather than tex-bibtex-tex.

### Strict scoping

Separately, one could imagine a promise of strict scoping. The preamble would be parsed to create a common initial state, and in between  `\begin{document}` `\end{document}` markers for the preprocessor could be used to demarcate the boundaries of independently-compilable sections of a document (i.e., sections that depend only on the DOM and the preamble state). Sample markers might be `\newpage` or `\chapter{}`, etc. This, in turn, opens the door to parallel document typesetting (followed by serial document generation). 

