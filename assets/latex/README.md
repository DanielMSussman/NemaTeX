# LaTeX Compatibility Layer (NemaTeX)

At the moment, when we compile the LaTeX format (via `./nematex latex.ltx`), we pretend to be XeTeX (for the pragmatic reason that we have unicode primitives but definitely do not have a `\directlua` equivalent.

Because our file resolver searches the local `assets/` directories before falling back to system TeX Live paths, this directory acts as a priority override. Files placed here intercept package loading to ensure LaTeX uses NemaTeX's native primitives (`\pushcolor`,`\restorestate`, `\setmatrix`, `\loadasset`, `\drawasset`, etc) rather than crashing or invoking unsupported driver specials.

## Modified and custom files

### `preload.cfg`

This file was copied from `/usr/share/texlive/texmf-dist/tex/latex/base/preload.cfg`, but modified to add legacy dimension aliases (so that I don't have to duplicate the primitives) and an automatic canvas synchronization hook for document classes:

### `color.cfg`

This file was copied from `/usr/share/texlive/texmf-dist/tex/latex/graphics-cfg/color.cfg`, but modified so that `color.sty` and `xcolor.sty` use `xetex.def`:
  ```latex
  \def\Gin@driver{xetex.def}
  \ExecuteOptions{xetex}
  ```
  This prevents `color.sty` from falling back to TeX Live's generic configuration.

### `xetex.def`

This file was copied from `/usr/share/texlive/texmf-dist/tex/latex/graphics-def/xetex.def`, but modified in a few ways.

  1. Replaced the dvipdfmx specials (`\special{color push ...}` and `\special{color pop}`) with an expl3 parser (`\nematex@setcolor`) that inspects `\current@color` (supporting `rgb`, `gray`, `cmyk`, and `xcolor` expressions) and dispatches directly to NemaTeX's native `\pushcolor R G B A` and `\popcolor` primitives.
  2. Changed the `\AtBeginDocument` page-sizing hook to refer to `\pagewidth` and `\pageheight`... I guess I could just make use of the preload.cfg to do this, but I edited this file first and haven't cleaned things up
  3. Replaced unsupported `\XeTeXpicfile` / `\XeTeXpdffile` calls and `\special{pdf:image}` in `\Gread@bmp`, `\Gread@pdf`, and `\Ginclude@nematex` with NemaTeX's native `\loadasset` / `\drawasset` / `\lastasset` primitives.

### `l3backend-xetex.def`

This file was copied from `/usr/share/texlive/texmf-dist/tex/latex/l3backend/l3backend-xetex.def`, but modified in a bunch of ways.

  1. (`l3backend-color.dtx`): Replaced dvipdfmx `pdf: bc` specials with native `\pushcolor` and `\popcolor` calls for `\__color_backend_select_rgb:n`, `\__color_backend_select_gray:n`, `\__color_backend_select_cmyk:n`, and `\__color_backend_reset:`.
  2. (`l3backend-basics.dtx`): Replaced `\special{x:gsave}` and `\special{x:grestore}` with `\tex_pdfsave:D` (`\savestate`) and `\tex_pdfrestore:D` (`\restorestate`), and defined matrix transformations via `\tex_pdfsetmatrix:D` (`\setmatrix`).
  3. (`l3backend-box.dtx`): Replaced XeTeX `x:rotate` / `x:scale` specials with pdfTeX-style trigonometric matrix evaluation using `\setmatrix`.
  4. (`l3backend-graphics.dtx`): Replaced unsupported `\XeTeXpicfile` and `\XeTeXpdffile` calls with NemaTeX's asset primitives (`\tex_pdfximage:D`, `\tex_pdflastximage:D`, and `\tex_pdfrefximage:D`).
  5. (`l3backend-pdfannot.dtx`): Make use of the native `\pdfannot`, `\pdfstartlink`, and `\pdfendlink` primitives.

### `graphics.cfg`

This file was copied from `/usr/share/texlive/texmf-dist/tex/latex/graphics-cfg/graphics.cfg`, but modified so that we use `pdftex.def` for the graphics driver (with legacy aliases for graphicx).


### `pdftex.def`

This file was copied from `/usr/share/texlive/texmf-dist/tex/latex/graphics-def/pdftex.def`. I patched image reading to use nematex's primitives (`\loadasset`, `\drawasset`, `\lastasset`), updated matrix state transformations to `\savestate` / `\restorestate` / `\setmatrix`, mapped page dimensions to `\pagewidth` and `\pageheight`, and guarded color hooks against undefined `\pdfcolorstack`.

### `geometry.cfg`

This is a custom file that Provides default paper size specifications (letter paper, 8.5in $\times$ 11in) for `geometry.sty` in NemaTeX.

### `epstopdf-base.sty`

Copied from `/usr/share/texlive/texmf-dist/tex/latex/epstopdf-pkg/epstopdf-base.sty`, but modified to remove the `\InputIfFileExists{epstopdf.cfg}{}{}` line (to prevent attempts to invoke external shell scripts during compilation).

### `fontmath.cfg`

Configures native OpenType math using Latin Modern Math (`latinmodern-math.otf`). Pre-declares mathematical font encodings (`TU`, `OML`, `OMS`, `OMX`, `U`), registers NFSS math alphabet hooks (`\mathbf`, `\mathbb`, etc.) so packages like `bbold` can safely redeclare them, releases conflicting package commands (`\iint`, `\ulcorner`) while providing `\AtBeginDocument` fallbacks for default documents, defines standard LaTeX math aliases (`\mathellipsis`, `\to`, `\triangle`, `\circ`, `\bullet`, `\diamond`, etc.), and defines `\newcounteralias` for modern `amsthm` hook compatibility.

### `hyperref.sty`

A lightweight compatibility stub that intercepts `\usepackage{hyperref}` and forwards to `nohyperref.sty`, preventing unsupported driver specials (`hxetex.def`) and engine dimension checks from failing while providing standard dummy hyperref commands.

### `language.dat`

Copied from `/usr/share/texlive/texmf-dist/tex/generic/config/language.dat`, but stripped down to only load US hyphenation patterns... this is just a convenience to slim down the format file (which, in turn, shaves off a few milliseconds). Eventually: support lazy loading of hyph patterns from the fmt file, so that we can include the whole thing in the fmt file but only pay for what we use.

### `tulmr.fd`, `tulmss.fd`, `tulmtt.fd`, `tulmvtt.fd`, `tulmssq.fd`

These files define the Latin Modern font families (`lmr`, `lmss`, `lmtt`, `lmvtt`, `lmssq`) under the `TU` encoding. We are pretending to be XeTeX, but NemaTeX expects direct font file paths ending in `.otf` rather than XeTeX's `\UnicodeFontFile` brackets syntax. These files map font declarations directly to the Latin Modern OpenType font files in `assets/latex/fonts/`.

### `pgf.cfg`

Configures the PGF system layer to automatically use NemaTeX's dedicated driver (`pgfsys-nematex.def`).

### `pgfsys-nematex.def`

PGF system driver for NemaTeX. Maps PGF drawing commands to direct PDF stream output via `\special`, defines picture lifecycle hooks (`\special{pdf:bcontent}` and `\special{pdf:econtent}`) for coordinate translation, interfaces with NemaTeX position-tracking primitives (`\savepos`, `\lastxpos`, `\lastypos`), and stubs resource definitions to prevent unsupported pdfTeX C-primitive invocations (`\pdfobj`). Also tries to use our `\floatevald` primitive for faster math.

