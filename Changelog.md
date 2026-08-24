TeX has its famous "converge to a pi" version system, and XeTeX adapted that / ZeroVer for its 0.x releases. We're going to have a little fun with our own scheme before giving in and switching to semantic versioning at 1.0.

Of course, the scientist in me loves the neat, orderly impression SemVer gives. But somehow bumping digits in a `MAJOR.MINOR.PATCH` pattern doesn't quite capture the feeling I get when working on this project. The feeling of gazing into the abyss of TeX82 bit packing and macro accessors, having the abyss gaze back, and then understanding that you should pack bits slightly differently in order to make a box node fit in exactly half of a cache line.

So, what is the scheme going to be? You should read the version numbers as an information radiator of technical debt. The planning note (`notes/roadmap.md`) describes features that are planned as various milestones, and we will adopt a convention in which the notation "0.2.3.7.[5]" means "We have completed what we set out to do in milestone 0, 1, 4, 5, 6, any milestone we have already planned higher than 7, but still have to do work on milestones 2, 3, and 7" (the number in square brackets indicates the number of completed milestones -- this exists so that the version string always monotonically increases, even if I happen to finish work on the last currently conceived milestone but haven't gotten to earlier items).

Think of this as a Chaos Muppet approach to versioning in the 0.X phase, when the concept of a breaking change, a new feature, or a patch is very much up for debate anyway. You can see how far away from 1.0 we are just by reading the version string and, even better, it has the delightful property that the version number can increase by pure thought. Feature creep, here we come!

I'm sorry if my obvious disregard for version parsers is upsetting. We should come up with a name for this scheme... strings of digits get eaten, but it's not really Ouroboros. Perhaps the Lernaean Hydra Scheme? Or Zeno's release candidate? I should probably add a milestone for "think of a good name."

# Current string: 0.7.8.9.10.11.13.14.15.16.18[9]

* finished implementing e-tex extensions -- etex trip test passes

#  0.7.8.9.10.11.13.14.15.16.18[9]

* Major reorganization of the memory array. 
    LuaTeX split the tokens off from the variable-sized nodes; we've gone a 
    step further and made a different pool of memory words for each different size of node.
    Greatly simplified logic for getting and freeing nodes

# 0.7.8.9.10.11.13.14.15.16.17[8]

* first set of architectural reorganizations

# 0.6.7.8.9.10.11.13.14.[7]

* Created a first HTML output backend (fixed-layout)
* simple "slides" format for demo, mp4 embedding, etc

# 0.6.7.8.9.10.11.12.13.[6]

* verapdf verication of UA2 compliance for ua2plain version of ua2gentle
* Basic MathML tagging

# 0.5.6.7.8.9.10.[5]

* Basic pdf generation implemented
* Implemented integration of OTF fonts with HarfBuzz
* Basic unicode math

# 0.4.5.[4]

* Removed interactive / REPL mode
* Initial refactoring of font system into manager communicating through the interfaces
* pageIR initiated

# 0.3.4.5.[3]

* Intermediate representation of a page created, some dependency injection, reduction of goto statements, and rough carving of system into classes.
* Asynchronous output backends


# 0.2.3.4.5.[2]

* Macros converted to inline functions
* Source split roughly into files
* All global variables collected into a single file


# 0.1.2.3.4.5.[1]

Cmake build, and `ctest` to run the TeX82 trip test 

# 0.0.1.2.3.4.5

It begins.
