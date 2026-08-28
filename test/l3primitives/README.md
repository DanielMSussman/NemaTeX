This is a small collection of tests for the behavior of primitives required by the l3kernel. 

I based the format of these tests largely on the `expanded.tex` file (David Carlisle and Bruno Le Floch, 2018) in the pdftex test suite. I have not tried to be particularly devious or trip-test-ish, and a fair criticism is that I am largely testing the happy path of these primitives. It's a place to start, though, before I begin working on the primitives themselves.

For each test, there is a `X.tex` file and a `X.log` file that represents what I believe is the correct output. My comparison script does play around with newlines for convenience, though (see `ComparePrimitiveFot.cmake` in this directory)
