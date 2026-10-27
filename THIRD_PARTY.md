# Third party components

This contains components from several open-source projects. Overall information, including where to find the relevant license files, can be found in the `licenses/` directory.

## Thread pool

The code for the `src/utility/thread_pool.h` file is a modernization of the classic C++11 implementation [from Progschj](https://github.com/progschj/threadpool), which is under the zlib license (full license in that file).

## MD5

The code in `src/utility/md5.h` and `src/utility/md5.cpp` is based on the MD5 implementation from Stephan Brumme's [hash-library](https://github.com/stbrumme/hash-library), which is released under the zlib License (full license header in those files).

## xxHash64

The code in `src/utility/xxhash64.h` is based on Stephan Brumme's [xxhash repo](https://github.com/stbrumme/xxhash), which is a specific implementation of Yann Collet's work. Brumme's code is released under the MIT license (full license header in the file).

## Pratt Parsing Algorithm

The way we do floating point expression evaluation for the `\floateval` primitive (with the binding-power formulation `(l_bp, r_bp)`) is inspired by and adapted from Alex Kladov's  [minipratt](https://github.com/matklad/minipratt) code and the [associated article](https://matklad.github.io/2020/04/13/simple-but-powerful-pratt-parsing.html). That code is under the MIT license.

## extern

The `extern/` directory additionally includes vendored code with license information for:
* [argh](https://github.com/adishavit/argh) (BSD-3) for command-line parsing
* [libdeflate](https://github.com/ebiggers/libdeflate) v1.22 (MIT license) for zlib/deflate compression
* [stb_image](https://github.com/nothings/stb) v2.30 (MIT or Unlicense) for asset decoding
* [tsl::robin-map](https://github.com/Tessil/robin-map) (MIT license) for a fast hash map
* [uni-algo](https://github.com/uni-algo/uni-algo) for unicode utilities (Public domain or MIT). Uses the `6c091fa` commit (Jan 5, 2024)
* [woff2](https://github.com/google/woff2) (MIT) for font compression.

