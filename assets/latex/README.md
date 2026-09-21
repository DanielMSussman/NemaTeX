# LaTeX Compatibility Layer (NemaTeX)

At the moment, when we compile the LaTeX format (via `./nematex latex.ltx`), we pretend to be XeTeX (for the pragmatic reason that we have unicode primitives but definitely do not have a `\directlua` equivalent.

Because our file resolver searches the local `assets/` directories before falling back to system TeX Live paths, this directory acts as a priority override. Files placed here intercept package loading to ensure LaTeX uses NemaTeX's native primitives (`\pushcolor`,`\restorestate`, `\setmatrix`, `\loadasset`, `\drawasset`, etc) rather than crashing or invoking unsupported driver specials.

Some files here are exact, unmodified copies of their TeX Live distribution counterparts... I'm doing this because I haven't yet written fast file searching into the engine, so discovering files in these small directories is much faster than recursively searching all of texlive. Other files actual contain important compatibility modifications.

## Verbatim copies from tex live

The following files are identical to their counterparts in the TeX Live distribution:

* `article.cls` — Standard LaTeX `article` document class.
* `epstopdf-sys.cfg` — System configuration stub for `epstopdf`.
* `geometry.sty` — Page geometry configuration package.
* `graphics.sty` — Standard LaTeX graphics package.
* `graphicx.sty` — Extended graphics package (`\includegraphics` key-value syntax).
* `ifetex.sty` — e-TeX engine detection stub.
* `ifluatex.sty` — LuaTeX engine detection stub.
* `ifpdf.sty` — PDF mode detection stub.
* `iftex.sty` — Engine identification package.
* `ifvtex.sty` — VTeX engine detection stub.
* `ifxetex.sty` — XeTeX engine detection stub.
* `keyval.sty` — Key-value option parser.
* `size10.clo` — Standard 10pt document size declarations.
* `supp-pdf.mkii` — ConTeXt MPS-to-PDF graphics converter.
* `trig.sty` — Trigonometric function evaluator for graphics rotations.
* `unicode-math-table.tex` — Unicode math symbol and operator definitions.

## Modified and custom files

### `preload.cfg`

This file was copied from `/usr/share/texlive/texmf-dist/tex/latex/base/preload.cfg`, but modified to add legacy dimension aliases (so that I don't have to duplicate the primitives):
  ```latex
  \ifx\pdfpagewidth\@undefined
    \let\pdfpagewidth\pagewidth
    \let\pdfpageheight\pageheight
  \fi
  ```

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
  2. Sanitized the `\AtBeginDocument` page-sizing hook to refer to `\pagewidth` and `\pageheight`... I guess I could just make use of the preload.cfg to do this, but I edited this file first and haven't cleaned things up

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

This file was copied from `/usr/share/texlive/texmf-dist/tex/latex/graphics-def/pdftex.def`. I patched image reading to use nematex's primitives (`\loadasset`, `\drawasset`, `\lastasset`), updated matrix state transformations to `\savestate` / `\restorestate` / `\setmatrix`, and mapped page dimensions to `\pagewidth` and `\pageheight`.

### `geometry.cfg`

This is a custom file that Provides default paper size specifications (letter paper, 8.5in $\times$ 11in) for `geometry.sty` in NemaTeX.

### `epstopdf-base.sty`

Copied from `/usr/share/texlive/texmf-dist/tex/latex/epstopdf-pkg/epstopdf-base.sty`, but modified to remove the `\InputIfFileExists{epstopdf.cfg}{}{}` line (to prevent attempts to invoke external shell scripts during compilation).

### `fontmath.cfg`

Copied from `/usr/share/texlive/texmf-dist/tex/latex/base/fontmath.cfg`, modified to pre-extract standard mathematical NFSS font declarations (`fontmath.ltx`) so math fonts load directly without needing external configuration files during format building.

### `language.dat`

Copied from `/usr/share/texlive/texmf-dist/tex/generic/config/language.dat`, but stripped down to only load US hyphenation patterns... this is just a convenience to slim down the format file (which, in turn, shaves off a few milliseconds). Eventually: support lazy loading of hyph patterns from the fmt file, so that we can include the whole thing in the fmt file but only pay for what we use.

### `tulmr.fd`

This file was copied from `/usr/share/texlive/texmf-dist/tex/latex/base/tulmr.fd`. We are pretending to be xetex, but don't load fonts in the same way, so this maps font declarations directly to the latin modern opentype font suite.

### `pgf.cfg`

Configures the PGF system layer to automatically use NemaTeX's dedicated driver (`pgfsys-nematex.def`).

### `pgfsys-nematex.def`

PGF system driver for NemaTeX. Maps PGF drawing commands to direct PDF stream output via `\special`, defines picture lifecycle hooks (`\special{pdf:bcontent}` and `\special{pdf:econtent}`) for coordinate translation, interfaces with NemaTeX position-tracking primitives (`\savepos`, `\lastxpos`, `\lastypos`), and stubs resource definitions to prevent unsupported pdfTeX C-primitive invocations (`\pdfobj`).

